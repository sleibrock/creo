#lang racket/base

(require (for-syntax racket/base))


;; Time some piece of code for testing purposes
(define-syntax-rule (time-it expr)
  (begin
    (let ([start-time (current-seconds)])
      (let ([result expr])
        (let ([end-time (current-seconds)])
          (printf "[TIMER] Operation took ~a seconds\n"
                  (- end-time start-time))
          (values result))))))


;; Provide an easy way of accessing a hash key
;; Provide an error value if no key exists in hash
(define-syntax Hash:get
 (syntax-rules ()
  [(get-key-or H) (raise-syntax-error "Hash:get: no key provided!")]
  [(get-key-or H K) (hash-ref H K)]
  [(get-key-or H K E)
    (cond
     [(hash-has-key? H K) (hash-ref H K)]
     [else E])]))


;; Easier substring than using `substring`
;; Takes a string, an index, or two indices, or no indices at all
(define-syntax String:sub
  (syntax-rules ()
    [(String:sub S) S]
    [(String:sub S upto)
      (let ([len (string-length S)])
        (if (< len upto) S (substring S 0 upto)))]
    [(String:sub S L R)
      (let ([len (string-length S)])
        (if (< L len)
            (if (< R len)
                (substring S L R)
                (substring S L len))
            ""))]))


;; Convert a system executable into a Racket plain function
(define-syntax-rule (defproc pname)
 (define pname
  (let ([procpath (find-executable-path (symbol->string 'pname))])
   (if (eqv? #f procpath)
       (error 'defproc "Executable not found, is it installed?")
       (lambda args
        (begin
         (define-values (S I O E)
          (apply
            subprocess
            `(,(current-output-port)
              ,(current-input-port)
              stdout
              ,procpath
              ,@args)))
         (subprocess-wait S)))))))



(module+ test
  (require rackunit)

  (check-eq? 0 0))
