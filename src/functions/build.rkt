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


(define/contract (process-file output-dir file-path)
  (-> path? path? void?)
  (define extn (File:type file-path))
  (unless (directory-exists? output-dir)
      (make-parent-directory* output-dir))
  (case extn
    ((markdown) (displayln "Caught a markdown file"))
    ((image) (begin
               (displayln "Copying an image file")
               (copy-file file-path (build-path output-dir file-path))))
    (else (void))))


(define/contract (CREO:build args)
  (-> list? void?)

  (displayln "Attempting to build the local CREO folder")

  (define public-dir (string->path "public"))

  ; define all tasks
  (define tasks
    (list
     ;(Task:make 'check_config (λ () (unless (file-exists? "config.creo") (error "CREO:build - config.creo not found"))))
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
      'build_dirs
      (λ ()
        (define (recurse-make-dirs d)
          (define files (directory-list d))
          (printf "Current directory: ~a\n" d)
          (printf "Scanned files: ~a\n" files)
          (for ([file-or-dir files])
            (cond
              ([directory-exists? file-or-dir]
               (make-directory* (build-path public-dir file-or-dir))
               (recurse-make-dirs file-or-dir))
              ([file-exists? file-or-dir]
               (process-file public-dir file-or-dir))
               (else (void)))))
        (recurse-make-dirs "content"))
        #:depends-on 'check_content)
               
        

     ))

  (Taskrun 4 tasks)
  (displayln "CREO:build subsystem completed"))

; end build.rkt
