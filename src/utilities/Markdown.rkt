#lang racket/base

#|
Markdown parsing and evaluation

File should contain

|#


(require (only-in racket/contract -> define/contract and/c or/c)
         (only-in racket/string string-trim string-replace string-prefix?)
         (only-in "Macros.rkt" String:sub)
         racket/match
         xml
         )

(provide (all-defined-out)
         )


;; Uses some string check logic to convert a raw string
;; into a markdown type cell
;;
;; Basic table:
;; #, ##, ###, ####, ##### = headers
;; 1..999 = an ordered list cell
;; * = an unordered list cell
;; [text]:[link] - a link dictionary appendage
;; @()  - a function call to some macro
(define (string->markdown-cell S)
  (define T (string-trim S))
  (match T 
    [(regexp #rx"\\[(.*)\\]:\\[(.*)\\](.*)" (list _ anc lnk etc))
     `(link-add (,anc ,lnk))]
    [(regexp #rx"@\\((.*)\\).*?" (list _ action)) `(eval ,action)]
    [(regexp #rx"#####(.*)" (list _ d))      `(h5 ,(string-trim d))]
    [(regexp #rx"####(.*)"  (list _ d))      `(h4 ,(string-trim d))]
    [(regexp #rx"###(.*)"   (list _ d))      `(h3 ,(string-trim d))]
    [(regexp #rx"##(.*)"    (list _ d))      `(h2 ,(string-trim d))]
    [(regexp #rx"#(.*)"     (list _ d))      `(h1 ,(string-trim d))]
    [(regexp #rx"\\*(.*)"   (list _ d))      `(ul ,(string-trim d))]
    [(regexp #rx"[0-9]*?\\.(.*)" (list _ d)) `(ol ,(string-trim d))]
    ["```" `(code)]
    ["---" `(hr)]
    [""    `(br)]
    [_     `(p ,T)]))


(module+ test
  (require rackunit)

  ; Perform basic unit testing on each branch
  (test-case "Checking string->markdown-cell functions"
    (check-equal? (string->markdown-cell "# Hello world!")
                  '(h1 "Hello world!"))
    (check-equal? (string->markdown-cell "## Hello world!")
                  '(h2 "Hello world!"))
    (check-equal? (string->markdown-cell "### Hello world!")
                  '(h3 "Hello world!"))
    (check-equal? (string->markdown-cell "#### Hello world!")
                  '(h4 "Hello world!"))
    (check-equal? (string->markdown-cell "##### Hello world!")
                  '(h5 "Hello world!"))
    (check-equal? (string->markdown-cell "I'm a paragraph!")
                  '(p "I'm a paragraph!"))
    (check-equal? (string->markdown-cell "33. Hello!")
                  '(ol "Hello!"))
    (check-equal? (string->markdown-cell "* I'm a cell!")
                  '(ul "I'm a cell!"))
    (check-equal? (string->markdown-cell "@(image https://google.com)")
                  '(eval "image https://google.com"))
    (check-equal? (string->markdown-cell "[anchor]:[https://google.com]")
                  '(link-add ("anchor" "https://google.com")))
    )

  )

; end Markdown
