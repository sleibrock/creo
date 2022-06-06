#lang racket/base


(require (only-in racket/contract define/contract ->)
         (only-in racket/list empty?)
         )


(provide List:join
         )

(define/contract (List:join l1 l2)
  (-> list? list? list?)
  (define (inner lcc ldrain)
    (if (empty? ldrain)
        lcc
        (inner (cons (car ldrain) lcc)
               (cdr ldrain))))
  (inner l1 l2))


; end GenPurpose.rkt
