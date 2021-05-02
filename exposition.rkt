#lang racket/base

(provide (all-defined-out))

(require racket/stream
         "metric.rkt")

(define (space p) (write-char #\space p))

(define (write-metric-help m [outp (current-output-port)])
  (when (metric-info m)
    (write-string "# HELP " outp)
    (write-string (metric-name m) outp)
    (space outp)
    (write-string (metric-info m) outp)
    (newline outp)))

(define (write-metric-type m [outp (current-output-port)])
  (when (metric-type m)
    (write-string "# TYPE " outp)
    (write-string (metric-name m) outp)
    (space outp)
    (write-string (symbol->string (metric-type m)) outp)
    (newline outp)))

;; XXX: actually escape values per the spec
(define (write-label-value s outp)
  (write-char #\" outp)
  (write-string s outp)
  (write-char #\" outp))

(define (write-metric-labels labels [outp (current-output-port)])
  ;; XXX: check for empty hash
  (when labels
    (define kvs (sequence->stream (in-hash labels)))
    (write-char #\{ outp)
    (define-values (k0 v0) (stream-first kvs))
    (write-string k0 outp)
    (write-char #\= outp)
    (write-label-value v0 outp)
    (for ([(k v) (in-stream (stream-rest kvs))])
      (write-char #\, outp)
      (write-string k outp)
      (write-char #\= outp)
      (write-label-value v outp))
    (write-string "} " outp)))

;; XXX: handle metric groups
(define (write-metric m [outp (current-output-port)])
  (write-metric-help m outp)
  (write-metric-type m outp)
  (write-string (metric-name m) outp)
  (space outp)
  (write-metric-labels (metric-labels m) outp)
  (write (metric-value m) outp)
  (space outp)
  (write (metric-time m) outp)
  (newline outp))

(define (write-exposition metrics [outp (current-output-port)])
  (for ([m (in-stream metrics)])
    (write-metric m outp)
    (newline outp)))

