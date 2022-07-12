#lang racket/base


(require (only-in racket/contract define/contract -> any/c)
         (only-in racket/list empty? range partition)
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


;; Partition a list into two lists based on a filter predicate
;; optionally, use the standard `partition` function in racket/list
(define/contract (List:partition L f)
  (-> list? (-> any/c boolean?) (values list? list?))
  (define (inner LL leftcc rightcc)
    (if (empty? LL)
        (cons (reverse leftcc)
              (reverse rightcc))
        (let ([head (car LL)]
              [tail (cdr LL)])
          (if (f head)
              (inner tail (cons head leftcc) rightcc)
              (inner tail leftcc (cons head rightcc))))))
  (let ([result (inner L '() '())])
    (values (car result) (cdr result))))




(module+ test
  (require rackunit
           "Macros.rkt"
           )
  )

; end GenPurpose.rkt
