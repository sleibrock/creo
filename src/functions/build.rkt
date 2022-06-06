#lang racket/base

(require (only-in racket/contract define/contract -> ->* any/c or/c)
         "../collections/Task.rkt"
         "../utilities/TaskRunner.rkt"
         )


(provide CREO:build)


(define/contract (folder-check folder)
  (-> string? (-> void?))
  (λ ()
    (unless (directory-exists? folder)
      (error (format "CREO:build - no ~a folder not found; is the project initialized?" folder)))))


(define/contract (CREO:build args)
  (-> list? void?)

  (displayln "Attempting to build the local CREO folder")


  ; define all tasks
  (define tasks
    (list
     ;(Task:make 'check_config (λ () (unless (file-exists? "config.creo") (error "CREO:build - config.creo not found"))))
     (Task:make 'check_content (folder-check "content"))
     (Task:make 'check_templates (folder-check "templates"))
     (Task:make 'check_templates (folder-check "scripts"))
     (Task:make 'check_styles (folder-check "styles"))))

  (Taskrun 4 tasks)
  (displayln "CREO:build subsystem completed"))

; end build.rkt
