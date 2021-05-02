#lang racket/base

(provide make-metric-server)

(require racket/pretty
         web-server/web-server
         web-server/http/response-structs
         (only-in web-server/dispatchers/dispatch-sequencer
                  [make dispatch-seq])
         (only-in web-server/dispatchers/dispatch-lift
                  [make dispatch-lift])
         (only-in web-server/dispatchers/dispatch-filter
                  [make filter-url])
         (only-in web-server/dispatchers/dispatch-method
                  [make filter-method])
         "endpoint.rkt")

(define TEXT/PLAIN-MIME-TYPE #"text/plain; charset=utf-8")

(define (file-not-found req)
  (response/output
   #:code 404
   #:mime-type TEXT/PLAIN-MIME-TYPE
   (lambda (outp)
     (displayln "file not found" outp)
     (pretty-display req outp))))

(define (make-metric-server #:metrics get-metrics-stream #:port port)
  (define endpoint (make-scrape-endpoint get-metrics-stream))
  (serve #:dispatch
         (dispatch-seq
          (filter-method 'GET
                         (filter-url #px"^/$"
                                     (dispatch-lift endpoint)))
          (dispatch-lift file-not-found))
         #:port port))

