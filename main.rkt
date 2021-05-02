#lang racket/base

(require racket/match
         web-server/web-server
         "metric.rkt"
         "metric-server.rkt"
         "sensor.rkt")

(define (get-sensor-metrics)
  (match (get-sensor-data)
    [(hash-table
       ['temperature_f tmp-f]
       ['temperature_c tmp-c]
       ['humidity      h]
       ['successes     s]
       ['checksum      chk]
       ['timeouts      to])
     (define tms (* (current-seconds) 1000))
     (list
       (metric "dht11_temperature_f" 'gauge #f #f tmp-f tms)
       (metric "dht11_temperature_c" 'gauge #f #f tmp-c tms)
       (metric "dht11_humidity"      'gauge #f #f h     tms)
       (metric "dht11_sensor_read_count" 'counter #f (hash "result" "success") s tms)
       (metric "dht11_sensor_read_count" #f       #f (hash "result" "timeout") to tms)
       (metric "dht11_sensor_read_count" #f       #f (hash "result" "checksum") chk tms))]
    [_ null]))

(define shutdown-server
  (make-metric-server #:metrics get-sensor-metrics
                      #:port 8080))

(with-handlers ([exn:break? (lambda (e) shutdown-server)])
  (do-not-return))
