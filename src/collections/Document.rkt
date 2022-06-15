#lang racket/base

(provide (struct-out Document)
         )


(struct Document (title contents date description)
  #:transparent)


; end Document.rkt
