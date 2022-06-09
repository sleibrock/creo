#lang racket/base

(require (only-in racket/contract define/contract -> or/c)
         (only-in racket/list empty?)
         (only-in racket/string string-split)
         "../collections/Queue.rkt"
         )



(provide File:extension
         File:type
         )


;: Convert a file into it's extension type
;; Errors if given a directory (how would that work?)
(define/contract (File:extension f)
  (-> (or/c path? string?) string?)
  (when (directory-exists? f)
    (error 'File:extension
           (format "expected file, given a directory ~a" f)))
  (define pp (if (path? f) (path->string f) f))
  (car (reverse (string-split pp "."))))


(define/contract (File:type f)
  (-> (or/c path? string?) symbol?)
  (define T (File:extension f))
  (case T
    (("md")    'markdown)
    (("jpg" "webp" "png" "gif" "jpeg") 'image)
    (("js")    'script)
    (("css")   'stylesheet)
    (("creo")  'config)
    (("rkt")   'racket)
    (("html" "txt")  'file)
    (("json" "toml") 'data)
    (else 'unknown)))
      


; end FileSysTools.rkt
  
               
