(ns word-counter.core
  (:require [clojure.string :as str]))

(defn count-words-in-chunk [text-chunk]
  (->> text-chunk
       (re-seq #"\w+")
       (map str/lower-case)
       frequencies))

(defn split-into-chunks [text num-chunks]
  (let [lines (str/split text #"\n")
        chunk-size (int (Math/ceil (/ (count lines) num-chunks)))]
    (partition-all chunk-size lines)))

(defn process-file [filename num-threads]
  (println "Reading file...")
  (let [text (slurp filename)
        chunks (split-into-chunks text num-threads)
        futures (doall (map #(future (count-words-in-chunk (str/join "\n" %))) chunks))
        results (map deref futures)
        total-counts (apply merge-with + results)]
    
    (println "Processing completed!")
    (println "Unique words:" (count total-counts))
    
    (println "\nTop-10 words:")
    (doseq [[word count] (take 10 (sort-by val > total-counts))]
      (printf "%-15s : %d\n" word count))
    
    total-counts))

(defn -main []
  (let [filename "large_text.txt"
        num-threads 4]
    (println "Starting word count in file:" filename)
    (println "Threads:" num-threads)
    (time (process-file filename num-threads))))