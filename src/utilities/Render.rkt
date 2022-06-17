#lang racket/base

#|
Rendering library for rendering Markdown files

Separated from Markdown.rkt to break up the functionality.
Goal is to provide functions that the Markdown files can use
and access to change contents and macro into more HTML.
|#

(require (only-in racket/contract -> or/c and/c define/contract)
         (only-in racket/file file->lines)
         (only-in racket/list empty?)
         "../collections/Document.rkt"
         "../utilities/Markdown.rkt"
         "../collections/Configuration.rkt"
         )

(define-namespace-anchor Render:Anchor)
(define Render:Namespace (namespace-anchor->namespace Render:Anchor))


; bind this filter function so we avoid repeat lambda init'ing
(define (is-action? cell)
  (eqv? 'action (car cell)))


(define/contract (markdown->Document fpath)
  (-> (and/c (or/c string? path?) file-exists?) Document?)

  ; convert file into lines split by \n
  (define doc-lines (file->lines fpath))

  ; convert lines to markdown lines
  (define markdown-cells (map string->markdown-cell doc-lines))

  (displayln "Rendering markdown actions")
  (parameterize ([current-namespace Render:Namespace])
    (for ([action (filter is-action? markdown-cells)])
      (displayln action)))
  (displayln "Done")

  (define output (markdown-builder markdown-cells '()))
  
  (Document "title"
            output
            "2022-10-31"
            "General page description"))



;; The second pass markdown parsing builder.
;; This looks at elements attributes and organizes them into the appropriate locations
;; The code must understand that certain elements need to be grouped,
;; and then when a group is started, write a flag indicating that we are inside
;; a state machine to evaluate to a given path now.
;;
;; example of pathways:
;; "1. hello" starts a list.
;;  |-> if next item is a list, keep collecting
;;  --> if the next item is not a list member, stop
;;    > collect all the items, reverse it, and append it
;;    > into a list of list-items ie '(ol (li "List item!") ...)
;; "```" starts a code block
;;  |-> keep collecting lines until we see another "```"
;;  |-> if we meet the ending bracket, collect the contents
;;  |-> and append it all in one big `(code x0 x1 ...) block
;;  --> if we reach the end of file, do the same thing
;;    > (lack of existence = end block at EOF)

(define (markdown-builder to-parse finalcc
                          #:groupcc  [groupcc '()]
                          #:is-code? [is-code? #f]
                          #:list?    [is-list? #f])
  (if (empty? to-parse)
      (cond
        (is-code?  {error "Unmatched code sequence!!"})
        ((not (eqv? #f is-list?))
         (markdown-builder to-parse
                           (cons (cons is-list? (reverse groupcc)) finalcc)))
        (else
         (reverse finalcc)))
      (let ([item (car to-parse)])
        (unless (list? item)
          (error "Item is not a list, invalid structure"))
        (let ([elem (car item)])
          (case elem
            (else
             (markdown-builder (cdr to-parse)
                               (cons item finalcc))))))))
         

  (define TESTRAW "
# Hello world!

I'm a test paragraph!

* This is a list item
* item 2
* item 3

---

Goodbye paragraph
")

(module+ main
  (displayln "Testing render")
  (call-with-output-file "TestFile.md"
    #:exists 'replace
    (λ (out)
    (parameterize ([current-output-port out])
      (displayln TESTRAW))))
  (define doc (markdown->Document "TestFile.md"))
  
  (displayln doc)
  
  (delete-file "TestFile.md")

  )

(module+ test
  (require rackunit)

  
  ;; Now we have the impossible goal of testing a full blown markdown
  ;; parsing system
  (test-case "Test successfully reading a file and converting it"
    (void))

  )


; end Render.rkt
