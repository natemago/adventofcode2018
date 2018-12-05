(require '(clojure [string :as string] test))

(defn alcreduce [s, base]
    (if (< (count s) 2) 
        (str base s) 
        (let [n (get s 0)
              nn (get s 1)]
              (if (= n nn) 
                (recur (subs s 1) (str base n)) ; ignore 
                (if (= (string/upper-case n) (string/upper-case nn)) 
                    (recur (subs s 2) base) 
                    (recur (subs s 1) (str base n)) ))) ))

(defn fullreduce [s]
    (let [ss (alcreduce s "")] 
        (if (= (count s) (count ss)) 
            s 
            (recur ss) ) ) )


(defn part1 [inp]
    (- (count (fullreduce (slurp inp))) 1))

(defn removeall [c s]
    (string/join "" (filter (fn [cc] 
        (not(= (string/upper-case c) (string/upper-case cc)))) s)))

(defn countreduced [s, c, m]
    (let [mm (count (fullreduce (removeall c s)))] 
        (if (< mm m) mm m)))

(defn part2 [inp] 
    (reduce (fn [m, c] (- (countreduced inp c m ) 1)) 1000000000 (seq "abcdefghijklmnopqrstuvwxyz")))


(print (str "Part 1: " (part1 "input") "\n"))
(print (str "Part 2: " (part2 (slurp "input")) "\n"))