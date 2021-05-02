#lang racket/base

(provide get-sensor-data)

(require net/http-easy
         racket/exn)

(define-logger sensor)

(define ((log-error-fail who msg) exn)
  (log-sensor-error "~a: ~a~%~a" who msg (exn->string exn))
  (raise exn))

(define http-timeouts
  (make-timeout-config #:lease   5
                       #:request 5
                       #:connect 5))

(define session (make-session))

(define (get-sensor-data)
  (with-handlers
      ([exn:fail?
        (log-error-fail 'get-sensor-data
                        "an error occurred")])
    (define rsp
      (session-request session
                       "http://alexandria.local:8080"
                       #:timeouts http-timeouts))
    (dynamic-wind
     void
     (lambda ()
       (response-json rsp))
     (lambda ()
       (response-close! rsp)))))

(module* main #f
  (let run ()
    (with-handlers ([exn:fail? (lambda (e) (log-sensor-info "eating exn"))])
      (get-sensor-data))
    (sleep 2)
    (run)))

