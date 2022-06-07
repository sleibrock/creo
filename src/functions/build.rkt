#lang racket/base

(require (only-in racket/contract define/contract -> ->* any/c or/c)
         (only-in racket/file make-directory* make-parent-directory* fold-files)
         "../collections/Task.rkt"
         "../utilities/TaskRunner.rkt"
         "../utilities/FileSysTools.rkt"
         )


(provide CREO:build)


(define/contract (folder-check folder)
  (-> string? (-> void?))
  (λ ()
    (unless (directory-exists? folder)
      (error
       (format "CREO:build - no ~a folder not found; is the project initialized?"
               folder)))))

(define (replace-content-with-public P)
  (apply build-path
         (cons (string->path "public")
               (cdr (explode-path P)))))


(define (public-create-dir target)
  (let ([new-path [replace-content-with-public target]])
    (if (directory-exists? new-path)
        (void)
        (make-directory* new-path))))

(define (public-process-file target)
  (let ([new-path [replace-content-with-public target]])
    (define type (File:type target))
    (case type 
      ((markdown) (displayln "Got a markdown file!"))
      ((image)    (displayln "Got an image file!"))
      (else (displayln "Got something else...")))))

(define/contract (CREO:build args)
  (-> list? void?)

  (displayln "Attempting to build the local CREO folder")

  (define public-dir (string->path "public"))

  ; define all tasks
  (define tasks
    (list
     ;(Task:make 'check_config (λ () (unless (file-exists? "config.creo")
     ;  (error "CREO:build - config.creo not found"))))
     (Task:make 'check_content   (folder-check "content"))
     (Task:make 'check_templates (folder-check "templates"))
     (Task:make 'check_static    (folder-check "static"))
     (Task:make 'check_styles    (folder-check "styles"))

     ; make the output build directory
     (Task:make 'make_public (λ () (make-directory* public-dir))
                #:depends-on 'check_content)
     
     ; recursively scan the content folder for files to copy/process
     ; or directories to build to the public directory
     (Task:make
      'build_content
      (λ ()
        (fold-files
         (λ (fpath ftype _)
           (printf "x:~a y:~a z:~a\n" ftype fpath _)
           (case ftype
             ((dir)  (public-create-dir fpath))
             ((file) (public-process-file fpath))
             (else   (printf "Links not supported, skipping\n"))))
         0
         "content"))
      #:depends-on 'check_content)

     (Task:make
      'make_static_public
      (λ ()
        (make-directory* (build-path "public" "static")))
      #:depends-on 'make_public)
     ))

  (Taskrun 4 tasks)
  (displayln "CREO:build subsystem completed"))

; end build.rkt
