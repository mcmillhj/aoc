
(require '[clojure.string])

(def positions 
    (->> 
        (clojure.string/split (slurp "7.txt") #",")
        (mapv #(Integer. %))))

(def solve (fn [cost-fn]
    (->> 
        (range (apply min positions) (apply max positions))
        (map (fn [to]
                (reduce + (for [from positions]
                            (cost-fn (Math/abs (- from to)))))))
        (reduce min))))

;; part 1
(solve identity)

;; part 2: use gaussian sum to avoid looping
(solve (fn [distance] (/ (* distance (+ distance 1)) 2)))