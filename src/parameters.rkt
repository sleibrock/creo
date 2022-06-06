#lang racket/base


(require (only-in racket/contract define/contract parameter/c any/c ->)
         )

(provide all-from-out)



(define/contract current-template-file
  (parameter/c string?)
  (make-parameter ""))



; end
