#lang racket/base

#|
Document structure

Should contain necessary metadata to render a singular page
Note: this does not cover the page entirely, whereas a page
can have many sub-pages underneath it.
This simply covers the basis of a simple markdown post
with associated writings.
|#


(provide (struct-out Document)
         )


(struct Document (title contents date description)
  #:transparent)


; end Document.rkt
