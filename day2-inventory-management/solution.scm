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


(define (list-diff l1 l2 rl i) 
    (if (null? l1) rl 
        (if (eq? (car l1) (car l2) ) 
            (list-diff (cdr l1) (cdr l2) rl (+ i 1) ) 
            (list-diff (cdr l1) (cdr l2) (cons i rl) (+ i 1)) ) ))


(define (ignore lst i n res) 
    (if (null? lst) (reverse res) 
        (if (= i n) 
            (ignore (cdr lst) (+ i 1) n res) 
            (ignore (cdr lst) (+ i 1) n (cons (car lst) res)) ) ))

(define (to-string lst) 
    (apply string lst))

(define (check-all inp-list) 
    (let ((result "<nope>")) 
        (map (lambda (i1) 
            (map (lambda (i2) 
                (if (not (eq? i1 i2 )) 
                    (let ((diff (list-diff (string->list i1) (string->list i2) '() 0 ))) 
                        (if (= (length diff) 1) 
                            (set! result (to-string (ignore (string->list i1) 0 (car diff) '() ) ) ) ) ) )) inp-list)) inp-list) result ) )


(define (part-2 input-file-name) 
    (check-all (load-input (open-input-file input-file-name) '() ) ))

(display "\n\nPart 2: ")
(display (part-2 "input"))
(display "\n\n")