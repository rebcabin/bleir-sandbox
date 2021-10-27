#lang br/quicklang

;;; Boilerplate for "re-exporting" the reader from "br/quicklang."
(module reader br/quicklang
  (provide read-syntax)
  (define (read-syntax name port)
    (define s-exprs (read port))
    (strip-bindings
     #`(module bleir-implementation bleir-sandbox  ;; funk name
         #,s-exprs))))

(provide (rename-out [bleir-expander #%module-begin]))
(define-macro (bleir-expander SEXP)
  #'(#%module-begin SEXP))

(require racket/pretty)

;;;FragmentCaller:
;;;    fragment=Fragment 
;;;    ( registers=( AllocatedRegister | MultiLineComment | SingleLineComment | TrailingComment ) )?
;;;    ( metadata=( CallerMetadata | Any ) )?
;;;    custom_caller=bool;

(provide FragmentCaller)
(define-macro-cases FragmentCaller

  [(FragmentCaller
    FRAGMENT
    REGISTERS-OR-METADATA
    CUSTOM-CALLER)
   #'(begin (raise "FragmentCaller, one option: not yet implemented"))]

  [(FragmentCaller
    FRAGMENT
    CUSTOM-CALLER)
   #'(begin (raise "FragmentCaller, no options: not yet implemented"))]

  [(FragmentCaller
    FRAGMENT
    REGISTERS
    METADATA
    CUSTOM-CALLER)  ; abstracted to avoid repetition
   #'(begin
       (pretty-print (map
                      (λ (x) (if (pair? x) (car x) x))
                      'FRAGMENT))
       FRAGMENT
       REGISTERS
       METADATA
       CUSTOM-CALLER)]

  [else #'(raise "FragmentCaller: unknown case")])

(require bleir-sandbox/parameters)
; re-export; TODO: is there a better solution?
(provide parameters)
(provide RN_REG)
(provide RE_REG)
(provide EWE_REG)
(provide L1_REG)
(provide L2_REG)
(provide SM_REG)


(provide fragment)
(define-macro (fragment Fragment
                        (identifier str ID)
                        PARMS
                        OPERS
                        DOCCOM
                        METADATA)
  #'(begin
      (pretty-print `(p-fragment ID ,PARMS ,METADATA))))


(provide custom_caller)  ; Note unidiomatic underscore
(define-macro (custom_caller bool BOOL-VAL)
  #'(begin (pretty-print '(p-custom-caller BOOL-VAL))))


(provide registers)
(define-macro-cases registers
  [(registers NoneType None)
   #'(begin (pretty-print '(p-registers None)))]
  [else (raise "registers: case not yet implemented.")])


(provide metadata)
(define-macro-cases metadata
  [(metadata dict VAL ...)
   #'(begin (pretty-print '(p-metadata VAL ...))
            (list 'VAL ...))]
  [(metadata ANY)
   #'(raise "metadata ANY: not yet implemented")]
  [else
   #'(raise "metadata: unknown case")]
  )


;;; END BLEIR DSL

(module+ test
  (require rackunit))


(module+ test
  ;; Any code in this `test` submodule runs when this file is run using DrRacket
  ;; or with `raco test`. The code here does not run when this file is
  ;; required by another module.

  (check-equal? (+ 2 2) 4))

(module+ main
  ;; (Optional) main submodule. Put code here if you need it to be executed when
  ;; this file is run using DrRacket or the `racket` executable.  The code here
  ;; does not run when this file is required by another module. Documentation:
  ;; http://docs.racket-lang.org/guide/Module_Syntax.html#%28part._main-and-test%29

  (require racket/cmdline)
  (define who (box "world"))
  (command-line
   #:program "my-program"
   #:once-each
   [("-n" "--name") name "Whom to say hello to" (set-box! who name)]
   #:args ()
   (printf "hello ~a~n" (unbox who))))

