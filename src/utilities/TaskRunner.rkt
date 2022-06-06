#lang racket/base


(require (only-in racket/list range empty?)
         "../collections/Queue.rkt"
         "../collections/Task.rkt"
         "Macros.rkt"
         )

(provide Taskrun)


; Run a thread that receives work, executes it, and notifies a supervisor
(define (make-worker n parent)
  (thread
   (λ ()
     (define (loop)
       (thread-send parent (list 'awaiting n 0))
       (define curtask (thread-receive)) ; wait for task
       (when (Task? curtask)
         (with-handlers ([exn? (λ (e) (displayln e) (exit))]) 
           ((Task-fn curtask))  ; block thread until task is finished
           (thread-send parent (list 'done n (Task-id curtask)))))
       (loop))
     (loop))))



;; Run a list of tasks by spawning N-worker threads and assign work
;; to each
(define (Taskrun n-workers tasks)
  (define indices (range n-workers))
  (define workers (make-vector n-workers #f))

  ; pre process the tasks into two collections
  (define (pre-process task-list)
    (define (inner tl qcc hcc)
      (if (empty? tl)
          (values qcc hcc)
          (let ([task (car tl)])
            (let ([dp (Task-depends-on task)])
              (inner (cdr tl)
                     (if (eqv? #f dp)
                         (Queue:snoc task qcc)
                         qcc)
                     (if (eqv? #f dp)
                         hcc
                         (if (hash-has-key? hcc dp)
                             (hash-update hcc dp (λ (tasks) (Queue:snoc task tasks)))
                             (hash-set hcc dp (Queue:init (list task))))))))))
    (inner task-list (Queue:empty)
           (make-immutable-hash '())))

  (define-values (task-queue dependents-hash)
    (pre-process tasks))

  (printf "Tasks: ~a\n" task-queue)
  (printf "Dependents: ~a\n" dependents-hash)

  (define supervisor
    (thread
     (λ ()
       (define (superloop Q H C)
         ;(printf "Superloop: ~a ~a ~a" Q H C)
         (when (or (Queue:not-empty? Q) (< 0 C))
           (define-values (msg thread# taskid)
             (apply values (thread-receive)))
           (printf "Received message: ~a ~a ~a\n" msg thread# taskid)
           (case msg
             ((awaiting)
              (if (Queue:not-empty? Q)
                  (begin
                    (thread-send (vector-ref workers thread#) (Queue:head Q))
                    (superloop (Queue:tail Q) H (add1 C)))
                  (superloop Q H C)))
             ((done)
                (if (hash-has-key? H taskid)
                    (superloop (Queue:append Q (hash-ref H taskid))
                               (Hash:update H taskid (Queue:empty))
                               (sub1 C))
                    (superloop Q H (sub1 C))))
             ((fail)
              (error "ERROR: system failure, check messages")
              (superloop Q H (sub1 C)))
             (else
              (error "ERROR: incorrect message type")))))
       (superloop task-queue dependents-hash 0))))

  (for ([x indices])
    (vector-set! workers x (make-worker x supervisor)))

  (thread-wait supervisor)
  
  (displayln "Finished running tasks"))

; end TaskRunner.rkt
