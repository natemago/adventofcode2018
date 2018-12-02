(define (count-letters letters-hash inp)
    (map (lambda (x) 
        (hash-table-set! letters-hash x (+ (hash-table-ref/default letters-hash x 0) 1) ))
            (string->list inp)))

(define (count-letters-hash inp) 
    (let ((lhash (make-strong-eq-hash-table 26))) (count-letters lhash inp) lhash))


(define (load-input input-port lst) 
    ( let ((line (read-line input-port))) 
        (cond ((eof-object? line) lst)
            (else (load-input input-port (cons line lst))))))

(define (sum lst)
    (if (null? lst) 0 (+ (car lst) (sum (cdr lst)))))

(define (has-count list-hash c) 
    (let ((it-does 0)) 
        (hash-table-walk list-hash (lambda (k v) 
                                        (if (= v c) (set! it-does 1)) ) ) it-does ))

(define (count-of inp-list n c) 
    (if (null? inp-list) c 
        (let ((lhash (count-letters-hash (car inp-list)))) 
            (count-of (cdr inp-list) n (+ c (has-count lhash n ) ) ) ) ))


(define (part-1 input-file-name) 
    (let ((inp-list (load-input (open-input-file input-file-name) '()))) 
        (*
            (count-of inp-list 2 0)
            (count-of inp-list 3 0))))

(display "Part 1: ")
(display (part-1 "input"))
(display "\n")