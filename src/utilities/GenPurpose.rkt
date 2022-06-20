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
;; Do not trust racket's partition function naturally since
;; it might do double-iteration (two filter calls instead of one pass)
(define/contract (List:partition L f)
  (-> list? (-> any/c boolean?) (values list? list?))
  (define (inner LL leftcc rightcc)
    (if (empty? LL)
        (values (reverse leftcc)
                (reverse rightcc))
        (let ([head (car LL)])
          (if (f head)
              (inner (cdr LL) (cons head leftcc) rightcc)
              (inner (cdr LL) leftcc (cons head rightcc))))))
  (inner L '() '()))




(module+ test
  (require rackunit
           "Macros.rkt"
           )

  (test-case "Test whether partition splits a list into two lists"
    (time-it (List:partition (range 1000) even?))
    (time-it (partition (range 1000) even?))
    )
  )

; end GenPurpose.rkt
