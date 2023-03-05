;; Constants
; (local level [[" " " " "#" "#" "#"]
;               [" " " " "#" "." "#"]
;               [" " " " "#" " " "#" "#" "#" "#"]
;               ["#" "#" "#" "$" " " "$" "." "#"]
;               ["#" "." " " "$" "@" "#" "#" "#"]
;               ["#" "#" "#" "#" "$" "#"]
;               [" " " " " " "#" "." "#"]
;               [" " " " " " "#" "#" "#"]])
(local level [["#" "#" "#" "#" "#"]
              ["#" "@" " " "." "#"]
              ["#" " " "$" " " "#"]
              ["#" "." "$" " " "#"]
              ["#" " " "$" "." "#"]
              ["#" "." "$" "." "#"]
              ["#" "." "*" " " "#"]
              ["#" " " "*" "." "#"]
              ["#" " " "*" " " "#"]
              ["#" "." "*" "." "#"]
              ["#" "#" "#" "#" "#"]])

(local cell-name {:player "@"
                  :player-on-storage "+"
                  :box "$"
                  :box-on-storage "*"
                  :storage "."
                  :empty " "
                  :wall "#"})

(local colors {(. cell-name :player) [0.64 0.53 1]
               (. cell-name :player-on-storage) [0.62 0.47 1]
               (. cell-name :box) [1 0.79 0.49]
               (. cell-name :box-on-storage) [0.59 1 0.5]
               (. cell-name :storage) [0.61 0.9 1]
               (. cell-name :wall) [1 0.58 0.82]})

(local cell-size 38)
(local font-scale (/ cell-size 25))

(local around {:left [-1 0] :right [1 0] :up [0 -1] :down [0 1]})

;; Debug methods
(fn debug-print [x y value name]
  (print (.. name " coords: " x " " y " value: (" value ")")))

(local fennel (require :fennel))
(fn _G.pp [x] (print (fennel.view x)))

;; Utility methods
(fn swap-cells [player-position direction src-cell dest-cell]
  (local [dx dy] (. around direction))
  (local [player-x player-y] player-position)
  (local (empty-x empty-y) (values (+ player-x dx) (+ player-y dy))) ; `y` comes first because `level` outter index is `y`
  (tset level player-y player-x (. cell-name dest-cell))
  (tset level empty-y empty-x (. cell-name src-cell)))

;; Love methods
(fn love.load []
  (love.graphics.setBackgroundColor 1 1 0.75))

(fn love.update [dt])

(fn love.draw []
  (each [y row (ipairs level)]
    (each [x cell (ipairs row)]
      (when (not= cell " ")
        ;; Draw non-empty cells
        (love.graphics.setColor (. colors cell))
        (love.graphics.rectangle :fill (* cell-size (- x 1))
                                 (* cell-size (- y 1)) cell-size cell-size)
        ;; Fill non-empty cells with symbols
        (love.graphics.setColor 1 1 1)
        (love.graphics.print (. level y x) (* cell-size (- x 1))
                             (* cell-size (- y 1)) 0 font-scale font-scale)))))

(fn love.keypressed [key]
  (when (or (= key :up) (= key :down) (= key :left) (= key :right))
    (var (player-x player-y) (values nil nil))
    (each [test-y row (ipairs level)]
      (each [test-x cell (ipairs row)]
        (when (or (= cell (. cell-name :player))
                  (= cell (. cell-name :player-on-storage)))
          (set (player-x player-y) (values test-x test-y)))))
    (local [dx dy] (. around key))
    (local current (. level player-y player-x))
    (local adjacent (. level (+ player-y dy) (+ player-x dx)))
    (local player-position [player-x player-y])
    (local next-player-position [(+ player-x dx) (+ player-y dy)])

    ;; TODO remove this and function
    (debug-print player-x player-y current :player)
    (debug-print (+ player-x dx) (+ player-y dy) adjacent key)

    (local beyond (?. level (+ player-y dy dy) (+ player-x dx dx)))

    (local next-adjacent {:empty :player
                          :storage :player-on-storage})
    (local next-adjacent-push {:box :player
                          :box-on-storage :player-on-storage})
    (local next-current {:player :empty
                          :player-on-storage :storage})
    (local next-beyond {:empty :box
                          :storage :box-on-storage})

    ;; TODO: continue refactoring
    (when (. next-adjacent adjacent)
      (print "boo"))

    ;; When we have player
    (when (= current (. cell-name :player))

      ;; If there is empty cell in front of him, move player there
      (if (= adjacent (. cell-name :empty))
          (swap-cells player-position key :player :empty))

      ;; If there is storage cell in front of him, move player there and change the wayhe is displayed
      (if (= adjacent (. cell-name :storage))
          (swap-cells player-position key :player-on-storage :empty))

      ;; When there is a box on storage and empty space in front of it
      (when (and (= adjacent (. cell-name :box-on-storage))
                 (= beyond (. cell-name :empty)))
        ;; Move player
        (swap-cells player-position key :player :empty)
        ;; Move box
        (swap-cells next-player-position key :box :player-on-storage))

      ;; When there is a box on storage and storage in front of it
      (when (and (= adjacent (. cell-name :box-on-storage))
                 (= beyond (. cell-name :storage)))
        ;; Move player
        (swap-cells player-position key :player :empty)
        ;; Move box
        (swap-cells next-player-position key :box-on-storage :player-on-storage))

      ;; When we have player and a box in front of him + space behind the box is empty
      (when (and (= adjacent (. cell-name :box))
                 (= beyond (. cell-name :empty)))
        ;; Move player
        (swap-cells player-position key :player :empty)
        ;; Move box
        (swap-cells next-player-position key :box :player))

      ;; When there is a box and storage in front of it  
      (when (and (= adjacent (. cell-name :box))
                 (= beyond (. cell-name :storage)))
        ;; Move player
        (swap-cells player-position key :player :empty)
        ;; Move box
        (swap-cells next-player-position key :box-on-storage
                    :player)))


    ;; When we have player standing on storage
    (when (= current (. cell-name :player-on-storage))
      ;; If there is empty cell in front of him, move player there
      (if (= adjacent (. cell-name :empty))
          (swap-cells player-position key :player :storage))
      ;; If there is storage in front of him, move player there
      (if (= adjacent (. cell-name :storage))
          (swap-cells player-position key :player-on-storage :storage))
      ;; When there is a box on storage and empty space in front of it
      (when (and (= adjacent (. cell-name :box-on-storage))
                 (= beyond (. cell-name :empty)))
        ;; Move player
        (swap-cells player-position key :player-on-storage :storage)
        ;; Move box
        (swap-cells next-player-position key :box :player-on-storage))
      ;; When there is a box on storage and storage in front of it
      (when (and (= adjacent (. cell-name :box-on-storage))
                 (= beyond (. cell-name :storage)))
        ;; Move player
        (swap-cells player-position key :player :storage)
        ;; Move box
        (swap-cells next-player-position key :box-on-storage :player-on-storage))
      ;; If there is a box and empty space in front of it
      (when (and (= adjacent (. cell-name :box))
                 (= beyond (. cell-name :empty)))
        ;; Move player
        (swap-cells player-position key :player :storage)
        ;; Move box
        (swap-cells next-player-position key :box :player))
      ;; If there is a box and storage in front of it  
      (when (and (= adjacent (. cell-name :box))
                 (= beyond (. cell-name :storage)))
        ;; Move player
        (swap-cells player-position key :player :storage)
        ;; Move box
        (swap-cells next-player-position key :box-on-storage
                    :player)))))
