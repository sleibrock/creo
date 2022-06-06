#lang racket/base


(require (only-in racket/contract define/contract parameter/c any/c ->)
         )

(provide (all-defined-out)
         )


(define/contract current-creo-actions
  (parameter/c hash?)
  (make-parameter (make-immutable-hash '())))

(define/contract (update-creo-actions key fn helpstr)
  (-> (-> any/c void?) string? string? void?)
  (let ([past (current-creo-actions)]
        [newval (cons helpstr fn)])
    (current-creo-actions
     (if (hash-has-key? past key)
         (hash-update past key (λ (_) newval)) 
         (hash-set past key newval)))))



(define/contract current-template-file
  (parameter/c string?)
  (make-parameter ""))



; end
