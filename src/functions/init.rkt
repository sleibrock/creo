#lang racket/base


(require (only-in racket/contract define/contract -> ->* any/c list/c or/c)
         "../collections/Task.rkt"
         "../utilities/TaskRunner.rkt"
         "../collections/Configuration.rkt"
         )

(provide CREO:init)


;; Provide a general wrapper for creating folders or erroring if they are made
(define (folder-maker . paths)
  (->* () #:rest (list/c (or/c path? string?)) (-> any/c void?))
  (λ ()
    (let ([p (apply build-path (cons (current-directory) paths))])
      (if (directory-exists? p)
          (error "CREO:init - directory already exists, try navigating to it or removing it")
          (make-directory p)))))


;; Initialize the main Creo project directory with sub-directories
;; Populate a directory with 
(define/contract (CREO:init args)
  (-> list? void?)

  (displayln "Attempting to initialize the CREO project")
  
  (when (eqv? '() args)
    (error "CREO:init - no project name given"))

  ; takes first value of args list - discard rest
  (define project-name (car args))


  ; more as required
  (define tasks
    (list
     ; make all the basic directories
     (Task:make 'root_dir (folder-maker project-name))
     (Task:make 'content (folder-maker project-name "content")
                #:depends-on 'root_dir)
     (Task:make 'static (folder-maker project-name "static")
                #:depends-on 'root_dir)

     ;; make the default themes folder and include default data
     (Task:make 'themes (folder-maker project-name "themes")
                #:depends-on 'root_dir)
     (Task:make 'base_theme (folder-maker project-name "themes" "base")
                #:depends-on 'themes)
     (Task:make 'styles (folder-maker project-name "themes" "base" "css")
                #:depends-on 'base_theme)
     (Task:make 'templates (folder-maker project-name "themes" "base" "templates")
                #:depends-on 'base_theme)
     (Task:make
      'write_default_css
      (λ ()
        (displayln "Writing default CSS file"))
      #:depends-on 'styles)
     (Task:make
      'write_default_template
      (λ ()
        (displayln "Writing default Template file"))
      #:depends-on 'templates)

     ; default index file
     (Task:make
      'write_default_index
      (λ ()
        (call-with-output-file
          (build-path project-name "content" "index.md")
          #:exists 'replace
          (λ (out)
            (parameterize ([current-output-port out])
              (displayln "# Welcome to Creo")
              )
        (displayln "Writing default index file"))
      #:depends-on 'content)

     ; generate a configuration file
     (Task:make 'make_config
                (λ ()
                  (let ([config-path (build-path project-name "config.creo")])
                    (unless (file-exists? config-path)
                      (Config:write-default config-path))))
                #:depends-on 'root_dir)
     ))

  (Taskrun 4 tasks)
  (displayln "CREO:init subsystem initialized"))


; end init.rkt
