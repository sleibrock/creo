#lang racket/base

#|
Rendering library for rendering Markdown files

Separated from Markdown.rkt to break up the functionality.
Goal is to provide functions that the Markdown files can use
and access to change contents and macro into more HTML.
|#

(require (only-in racket/contract -> or/c and/c define/contract)
         (only-in racket/file file->lines)
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
  (define markdown-data (map string->markdown-cell doc-lines))

  (displayln "Rendering markdown actions")
  (parameterize ([current-namespace Render:Namespace])
    (for ([action (filter is-action? markdown-cells)])
      (displayln action)))
  (displayln "Done")
  
  (Document "title"
            '(contents)
            "2022-10-31"
            "General page description"))


; end Html.rkt
