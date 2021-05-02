#lang racket/base

(require racket/contract)

(define metric-type/c
  (or/c 'counter 'gauge))

(provide
  (contract-out
    [struct metric
            ([name   string?]
             [type   (or/c #f metric-type/c)]
             [info   (or/c #f string?)]
             [labels (or/c #f (hash/c string? string?))]
             [value  real?]
             [time   exact-nonnegative-integer?])]))

(struct metric (name type info labels value time) #:transparent)

