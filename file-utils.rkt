#lang racket

;;; Brian Beckman, 19 Oct 2021
;;;
;;; Run this script to prepare racket files for distribution
;;; by removing lengthy annotations supplied by DrRacket,
;;; specifically for code-folding (collapse and expand s-exp
;;; on right-clicking an open paren insert a very large
;;; number of illegible annotations into a .rkt file).
;;;
;;; A file with .rkt extension /may/ have DrRacket annotations,
;;; that is, the file may be in GRacket format, called wxme
;;; internally to the racket documentation. Test whether a
;;; given .rkt file is in wxme format. If so, copy the file
;;; to a .gdr file with the same prefix, e.g., copy foo.rkt to
;;; foo.gdr, then strip with wxme annotations from foo.rkt
;;;
;;; The script currently works on a manifest list of file
;;; prefixes, e.g., "main," "parameters," etc. Eventually, as
;;; trust grows in this method, we can enumerate all the .rkt
;;; files in the directory aggressively, and even make this
;;; script a .git push hook

(require wxme)

(provide (contract-out
          [textify (-> path-string? path-string? void?)]))

(define (textify in-file out-file)
  (if (and (file-exists? in-file)
           (call-with-input-file in-file is-wxme-stream?))
      (call-with-input-file in-file
        (lambda (in-port)
          (call-with-output-file out-file
            (lambda (out-port)
              (copy-port (wxme-port->text-port in-port)
                         out-port))
            #:exists 'replace)))
      (void)))

(for-each (lambda (file-nym)
            (let ((maybe-gdr (string-append-immutable
                            "./" file-nym ".rkt"))
                  (definitely-gdr (string-append-immutable
                                   "./" file-nym ".gdr")))
              (if (and (file-exists? maybe-gdr)
                       (call-with-input-file maybe-gdr is-wxme-stream?))
                  (begin (copy-file maybe-gdr definitely-gdr #t)
                         (textify definitely-gdr maybe-gdr))
                  (void))))
          '("main"
            "parameters"
            "tartan-py--tartan-or-equals"))
