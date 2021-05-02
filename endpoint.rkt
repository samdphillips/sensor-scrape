#lang racket/base

(provide make-scrape-endpoint)

(require racket/exn
         web-server/http/response-structs
         "exposition.rkt")

(define TEXT/PLAIN-MIME-TYPE #"text/plain; charset=utf-8")

(define (error-response e)
  (response/output
   #:code 500
   #:mime-type TEXT/PLAIN-MIME-TYPE
   (lambda (outp)
     (write-string (exn->string e) outp))))

(define ((make-scrape-endpoint get-metrics-stream) request)
  (with-handlers ([exn:fail? error-response])
    (define metrics (get-metrics-stream))
    (response/output
     #:mime-type TEXT/PLAIN-MIME-TYPE
     (lambda (outp) (write-exposition metrics outp)))))

#;
(define ((make-scrape-endpoint get-metrics-stream) request)
  (with-handlers ([exn:fail? error-response])
    (response/output
     #:mime-type TEXT/PLAIN-MIME-TYPE
     (lambda (outp) (write-exposition (get-metrics-stream) outp)))))
