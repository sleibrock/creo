#lang racket/base


(require (only-in racket/contract define/contract -> any/c or/c))

(provide (struct-out Queue)
         Queue:init         ; List a -> Q a 
         Queue:empty        ; () -> Q
         Queue:empty?       ; Q -> Boolean
         Queue:not-empty?   ; Q -> Boolean
         Queue:snoc         ; a -> Q a -> Q a
         Queue:head         ; Q a -> Maybe a
         Queue:tail         ; Q a -> Maybe Q a
         Queue:append       ; Q a -> Q a -> Q a
         )


;; A Queue provides the ability to push and pop in a linear manner,
;; providing a first-in-first-out data structure.
;; Definition of Queue functions are all purely functional
(struct Queue (front rear count) #:transparent)



;; A smart constructor to lift difficulty off functions
;; fun queue { F = [ ], R = r } => Queue { F = rev r , R = [ ] }
;;     queue { F = f , R = r } => Queue { F = f , R = r } 
(define/contract (_q F R c)
  (-> list? list? number? Queue?)
  (if (eqv? '() F)
      (Queue (reverse R) '() c)
      (Queue F R c)))


;; Create an empty queue for initialization
(define/contract (Queue:empty)
  (-> Queue?)
  (Queue '() '() 0))


;; A testing predicate to see if a Queue is empty.
;; Completes an exhaustive check on all properties
(define/contract (Queue:empty? q)
  (-> Queue? boolean?)
  (and (eqv? '() (Queue-front q))
       (eqv? '() (Queue-rear q))
       (eqv? 0 (Queue-count q))))


(define/contract Queue:not-empty?
  (-> Queue? boolean?)
  (compose not Queue:empty?))


;; A queue is initialized from some given collection.
;; Supports list or vector, must be ordered. No hashes.
(define/contract (Queue:init items)
  (-> (or/c list? vector?) Queue?)
  (foldl Queue:snoc (Queue:empty) items))


;; Append a data element to the end of the queue
;; fun snoc (Queue fF = f , R = r g, x ) = queue fF = f , R = x :: r g
(define/contract (Queue:snoc x q)
  (-> any/c Queue? Queue?)
  (_q (Queue-front q) 
      (cons x (Queue-rear q))
      (add1 (Queue-count q))))



;; View what is at the front of the list
;; If nothing, yield an error
(define/contract (Queue:head q)
  (-> Queue? any/c)
  (if (Queue:empty? q)
      (error "Queue is empty, cannot remove an element")
      (car (Queue-front q))))


;; View what is at the end of the queue
;; If nothing, yield an error
;; fun tail Queue { F = x :: f , R = r } => queue { F = f , R = r } 
(define/contract (Queue:tail q)
  (-> Queue? any/c)
  (let ([front (Queue-front q)])
    (if (eqv? '() front)
        (error "Nothing")
        (_q (cdr front)
            (Queue-rear q)
            (sub1 (Queue-count q))))))


; Map a function over all items in the queue
; A for-each is not provided as order is not maintained
; in this representation of queue (since rear items are backwards)
(define/contract (Queue:map q f)
  (-> Queue? (any/c . -> . any/c) Queue?)
  (Queue (map f (Queue-front q))
         (map f (Queue-rear q))
         (Queue-count q)))


(define/contract (Queue->list q)
  (-> Queue? list?)
  (define (inner qcc lcc)
    (if (Queue:empty? qcc)
        lcc
        (inner (Queue:tail qcc)
               (cons (Queue:head qcc) lcc))))
  (reverse (inner q '())))


(define/contract (Queue:append q1 q2)
  (-> Queue? Queue? Queue?)
  (define (inner qcc qdrain)
    (if (Queue:empty? qdrain)
        qcc
        (inner (Queue:snoc (Queue:head qdrain) qcc)
               (Queue:tail qdrain))))
  (inner q1 q2))


;; Tests for the Queue module
(module+ test
  (require rackunit)


  (test-case "Test for empty queues"
    (define q (Queue:empty))
    (check-eq? #t (Queue:empty? q))
    (check-eq? #f (Queue:not-empty? q))


    ; Create a queue, then drain it fully via recursion
    (define s (Queue:init '(1 2 3 4 5)))
    (define (loop-til-empty q)
      (if (Queue:empty? q)
          q
          (loop-til-empty (Queue:tail q))))
    (define new-queue (loop-til-empty s))
    (check-eq? 0 (Queue-count new-queue))
    )


  (test-case "Test for appending two queues"
    (define q1 (Queue:init '(1 2 3 4 5)))
    (define q2 (Queue:init '(6 7 8 9 10)))
    (define q3 (Queue:append q1 q2))
    (check-eqv? '(1 2 3 4 5 6 7 8 9 10)
               (Queue->list q3)))

  (displayln "Tests complete")
  )

; end Queue.rkt
