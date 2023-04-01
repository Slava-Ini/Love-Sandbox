(local fennel (require :fennel))
(local {: levels } (require :levels))

;; --- Constants
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

;; --- Globals
(var current-level 1)
(var level [])

;; --- Utility methods
(fn swap-cells [src-position direction src-cell dest-cell]
  (local [dx dy] (. around direction))
  (local [src-x src-y] src-position)
  (local (dest-x dest-y) (values (+ src-x dx) (+ src-y dy))) 
  (tset level src-y src-x src-cell)
  (tset level dest-y dest-x dest-cell))

(fn load-level []
  (set level [])
  (if (not= (. levels current-level) nil)
    (each [y row (ipairs (. levels current-level))]
      (tset level y [])
      (each [x cell (ipairs row)]
        (tset level y x cell)))))

(fn load-next-level []
  (set current-level (+ current-level 1))
    (if (> current-level (length levels))
      (set current-level 1))
    (load-level))

;; --- Love methods
(fn love.load []
  (love.graphics.setBackgroundColor 1 1 0.75)
  (load-level))

(fn love.update [dt])

(fn love.draw []
  (each [y row (ipairs level)]
    (each [x cell (ipairs row)]
      (when (not= cell " ")
        ;; - Draw non-empty cells
        (love.graphics.setColor (. colors cell))
        (love.graphics.rectangle :fill (* cell-size (- x 1))
                                 (* cell-size (- y 1)) cell-size cell-size)
        ;; - Fill non-empty cells with symbols
        (love.graphics.setColor 1 1 1)
        (love.graphics.print (. level y x) (* cell-size (- x 1))
                             (* cell-size (- y 1)) 0 font-scale font-scale)))))

(fn love.keypressed [key]
  ;; - Load next level
  (when (= key :n)
    (load-next-level))

  ;; - Load previous level
  (when (= key :p)
    (set current-level (- current-level 1))
    (if (< current-level 1)
      (set current-level (length levels)))
    (load-level))

  ;; - Reset level
  (when (= key :r)
    (load-level))

  ;; - Move player
  (when (or (= key :up) (= key :down) (= key :left) (= key :right))
    (var (player-x player-y) (values nil nil))
    (var is-complete true)

    ;; - Find player position
    (each [y row (ipairs level)]
      (each [x cell (ipairs row)]
        (when (or (= cell (. cell-name :player))
                  (= cell (. cell-name :player-on-storage)))
          (set (player-x player-y) (values x y)))))

    ;; - Define player coordinates
    (local [dx dy] (. around key))
    (local player-position [player-x player-y])
    (local next-player-position [(+ player-x dx) (+ player-y dy)])

    ;; - Define cells values
    (local current (. level player-y player-x))
    (local adjacent (. level (+ player-y dy) (+ player-x dx)))
    (local beyond (?. level (+ player-y dy dy) (+ player-x dx dx)))

    ;; - Define rules of movement
    (local next-adjacent
           {(. cell-name :empty) (. cell-name :player)
            (. cell-name :storage) (. cell-name :player-on-storage)})
    (local next-adjacent-push
           {(. cell-name :box) (. cell-name :player)
            (. cell-name :box-on-storage) (. cell-name :player-on-storage)})
    (local next-current
           {(. cell-name :player) (. cell-name :empty)
            (. cell-name :player-on-storage) (. cell-name :storage)})
    (local next-beyond
           {(. cell-name :empty) (. cell-name :box)
            (. cell-name :storage) (. cell-name :box-on-storage)})

    ;; - Define the movement of player to adjacent cell by rules
    (when (. next-adjacent adjacent)
      (let [dest (. next-adjacent adjacent)
            src (. next-current current)]
        (swap-cells player-position key src dest)))

    ;; - Define the box push and corresponding player movement according to rules
    (when (and (. next-beyond beyond) (. next-adjacent-push adjacent))
      (let [push-dest (. next-beyond beyond)
            push-src (. next-adjacent-push adjacent)
            src (. next-current current)]
        (swap-cells next-player-position key push-src push-dest)
        (swap-cells player-position key src push-src)))
    
    ;; - Check if the level is complete
    (each [y row (ipairs level)]
      (each [x cell (ipairs row)]
        (if (= cell (. cell-name :box))
          (set is-complete false))))
    
    (if is-complete
      (load-next-level))))
