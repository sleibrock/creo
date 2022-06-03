#lang racket/base


(require (only-in racket/cmdline command-line))

(command-line
 #:program "creo"
 #:args (action . args)

 (displayln "Welcome to Creo!")
 (displayln (format "action: ~a" action))
 (displayln (format "args: ~a" args)))
