#lang racket/base

(require (only-in racket/contract define/contract -> ->* any/c or/c))

(provide (struct-out Task)
         Task:make
         Task->thread
         )

#|
The Task data type

The goal of the task is to represent some function that needs
to be processed. Once it's processed, it's state is finalized,
and can be replaced or modified with a new task.

The goal is to create a representation of two types of tasks

* Independent task
* Dependent task

The Dependent task connects to another task via the TaskRunner
system through a hashmap connection. A task is considered a
dependent if it requires another task to finish it's job before
it can begin execution.

Let's say we have two tasks, A and B, and each perform an operation.
A is an independent task, while B requires A to complete before
it can complete it's job.

[Task A] <- [Task B]

Task A must finish it's job, and when it does, a system exists
to notify Task B that it can begin it's task.

In this document, we define a Task as a struct, and introduce
a generalized constructor that can differentiate between
independent and dependent tasks, such that the user does not
have to directly use the struct constructor.

This doc does not contain the Task Runner system code.
|#


(struct Task (id fn depends-on))


;; Make a task with an identifier
(define/contract (Task:make id fn #:depends-on [dp #f])
  (->* (any/c (-> void?)) (#:depends-on (or/c boolean? any/c)) Task?)
  (Task id fn dp))



;; Turn a task into a thread
;; The new thread will execute the Task's associated function
;; At the end, it will do a thread-send to the Output thread
;; which will use the Task's ID as a way of knowing what task finished
(define/contract (Task->thread T O)
  (-> Task? thread? thread?)
  (thread
   (λ ()
     ((Task-fn T))
     (thread-send O (Task-id T)))))






; end Task.rkt
