#lang racket/base


(require (only-in racket/cmdline command-line)
         "parameters.rkt"
         "functions/init.rkt"
         )

(command-line
 #:program "creo"
 #:help-labels "What does this do?"
 #:usage-help "Creo - where your dreams become reality"
 #:args (action . args)

 (displayln "Welcome to Creo!")
 (displayln (format "action: ~a" action))
 (displayln (format "args: ~a" args))


 (case action
   (("init") (CREO:init args))
   (else (error "No valid action given"))))


; end main.rkt
