#lang racket/base


(require (only-in racket/contract define/contract -> ->* any/c list/c or/c)
         "../collections/Task.rkt"
         "../utilities/TaskRunner.rkt"
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
     (Task:make 'root_dir (folder-maker project-name))
     (Task:make 'templates (folder-maker project-name "templates")
                #:depends-on 'root_dir)
     (Task:make 'content (folder-maker project-name "content")
                #:depends-on 'root_dir)
     (Task:make 'styles (folder-maker project-name "styles")
                #:depends-on 'root_dir)

     ))

  (Taskrun 4 tasks)
  (displayln "CREO:init subsystem initialized"))


; end init.rkt
