#lang racket/base


(require (only-in racket/cmdline command-line)
         "parameters.rkt"

         ; import the CREO entrypoint functions
         "functions/init.rkt"
         "functions/build.rkt"
         )


(command-line
 #:program "creo"
 #:usage-help "Creo - where your dreams become reality"
 #:args (target . args)

 (displayln "Welcome to Creo!")

 (case target
   (("init") (CREO:init args))
   (("build") (CREO:build args))
   (else (displayln "No valid action given"))))


 
; end main.rkt
