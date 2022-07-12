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

  ; Use the markdown builder tool to properly execute cells
  (define output (markdown-builder markdown-cells '()))
  
  (Document "title"
            (strip-front-newlines output)
            "2022-10-31"
            "General page description"))


;; two shortcut functions to help convert list items
(define (convert-list-cell p)
  (cons 'li (cdr p)))

;; List cells are often contained backwards, so this applies reverse $ map f lst
(define (convert-list-cells ps)
  (reverse (map convert-list-cell ps)))


;; A helper function to strip and un-head-ify incoming
;; items for a code block
;; TODO: might require a Queue to keep in order
(define (append-code-cell cellcc p)
  0)

;; Continusouly pop a list until the front of the list is no longer
;; a linebreak
(define (strip-front-newlines contents)
  (if (empty? contents)
      '()
      (let ([head (car contents)])
        (if (empty? head)
            (strip-front-newlines (cdr contents))
            (let ([key (car head)])
              (case key
                ((br) (strip-front-newlines (cdr contents)))
                (else contents)))))))
  



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
         (markdown-builder '()
                           (cons (cons is-list? (convert-list-cells groupcc))
                                 finalcc)))
        (else
         (reverse finalcc)))
      (let ([item (car to-parse)])
        (unless (list? item)
          (error "Item is not a list, invalid structure"))
        (let ([elem (car item)])
          (case elem
            ('ol  (markdown-builder (cdr to-parse) finalcc
                                     #:groupcc (cons item groupcc)
                                     #:list? 'ol))
            ('ul  (markdown-builder (cdr to-parse) finalcc
                                     #:groupcc (cons item groupcc)
                                     #:list? 'ul))
            ('code (if is-code?
                        (markdown-builder (cdr to-parse) (cons `(code ,groupcc) finalcc)) 
                        (markdown-builder (cdr to-parse) finalcc #:is-code? #t)))
            (else
             (cond
               (is-code?
                (markdown-builder (cdr to-parse) finalcc
                                  #:groupcc (cons item groupcc)
                                  #:is-code? #t))
               ((not (eqv? #f is-list?))
                (markdown-builder (cdr to-parse)
                                  (cons (cons is-list? (convert-list-cells groupcc))
                                        finalcc)))
               (else
                (markdown-builder (cdr to-parse)
                                  (cons item finalcc))))))))))
      

(define TESTRAW "
@(title \"This is a post brah\")

# Hello world!

I'm a test paragraph!

* This is a list item
* item 2
* item 3

```
this text is inside a block of code
same as this line
```

---

Goodbye paragraph")

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


  ;; test removing the head of a list if it's empty or a <br> line
  (test-case "Testing whether removing front of the list if empty"
    (check-equal? (strip-front-newlines '(() () (br)))
                  '())
    (check-equal? (strip-front-newlines '(() (br) (p "Hi")))
                  '((p "Hi")))
    (check-equal? (strip-front-newlines '(() () (br) () () (br) (p "hi")))
                  '((p "hi"))))
  
  ;; Now we have the impossible goal of testing a full blown markdown
  ;; parsing system
  (test-case "Test successfully reading a file and converting it"
    (void))

  )


; end Render.rkt
