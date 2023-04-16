;; --- Constants
(local grid-x-count 20)
(local grid-y-count 15)
(local cell-size 30)
(local around {:left [-1 0] :right [1 0] :up [0 -1] :down [0 1]})

;; --- State
(var snake-segments [])
(var direction-queue [:right])
(var food-position { :x 1 :y 1 })
(var is-snake-alive true)
(var timer 0)

;; --- Helpers
(fn draw-cell [x y]
  (love.graphics.rectangle :fill
    (-> x (- 1) (* cell-size))
    (-> y (- 1) (* cell-size))
    (- cell-size 1)
    (- cell-size 1)))

(fn move-food []
  (var is-valid-position true)

  (local new-food-position { :x (math.random 1 grid-x-count) :y (math.random 1 grid-y-count) })
  (local { :x new-food-x :y new-food-y } new-food-position)

  (each [_ segment (ipairs snake-segments)]
    (if (match [(. segment :x) (. segment :y)]
           [new-food-x new-food-y] true
           _ false)
             (set is-valid-position false)))

  (if is-valid-position
    (set food-position new-food-position)
    (move-food)))

(fn reset-game []
  (set direction-queue [:right])
  (set snake-segments [{ :x 3 :y 1 } { :x 2 :y 1 } { :x 1 :y 1 }])
  (set is-snake-alive true)
  (move-food))


;; --- Love methods
(fn love.load []
  (love.window.setMode (* grid-x-count cell-size) (* grid-y-count cell-size) { :resizable false })
  (reset-game))

(fn love.update [dt]
  (set timer (+ timer dt))

  (when (>= timer 0.1)
    (if (> (length direction-queue) 1)
      (table.remove direction-queue 1))

    (let [[around-x around-y] (. around (. direction-queue 1))] 
      (var next-x-position (-> snake-segments (. 1) (. :x) (+ around-x)))
      (var next-y-position (-> snake-segments (. 1) (. :y) (+ around-y)))

      ;; - Checking if snake collapsed on itself
      (each [_ segment (ipairs snake-segments)]
        (if (match [(. segment :x) (. segment :y)]
               [next-x-position next-y-position] true
               _ false)
                 (set is-snake-alive false)))
      
      ;; - Moving snake
      (when is-snake-alive
        (when (or (< next-x-position 1) (> next-x-position grid-x-count))
          (set next-x-position (if (= next-x-position 0) grid-x-count 1)))
        (when (or (< next-y-position 1) (> next-y-position grid-y-count))
          (set next-y-position (if (= next-y-position 0) grid-y-count 1)))

        (table.insert snake-segments 1 { :x next-x-position :y next-y-position })

        ;; - Eating food
        (if (match [(. food-position :x) (. food-position :y)]
              [next-x-position next-y-position] true
              _ false)
          (move-food)
          (table.remove snake-segments))
        (set timer 0))))
  
  ;; - Resetting game in 2 seconds
  (when (not is-snake-alive)
    (if (>= timer 2)
     (reset-game))))

(fn love.keypressed [key]
   (when (and
     (or (= key "left") (= key "right") (= key "up") (= key "down"))
     ;; - Prevent snake to move through itself 
     (not (match [(. direction-queue (length direction-queue)) key]
             [:left :right] true
             [:right :left] true
             [:up :down] true
             [:down :up] true
             _ false))
     ;; - Prevent duplicate directions
     (not (= (. direction-queue (length direction-queue)) key)))
       (table.insert direction-queue key)))

(fn love.draw []
  (love.graphics.setColor 0.28 0.28 0.28)
  (love.graphics.rectangle :fill 0 0 (* grid-x-count cell-size) (* grid-y-count cell-size))

  (each [index segment (ipairs snake-segments)]
    (if is-snake-alive
      (if (= index 1)
        (love.graphics.setColor 0.6 1 0.32)
        (love.graphics.setColor 0.6 0.6 0.20))
      (if (= index 1)
        (love.graphics.setColor 0.4 0.4 0.4)
        (love.graphics.setColor 0.5 0.5 0.5)))
    (draw-cell (. segment :x) (. segment :y)))
  
  (love.graphics.setColor 1 0.3 0.3)
  (draw-cell (. food-position :x) (. food-position :y))
  
  (love.graphics.setColor 1 1 1)
  (love.graphics.print (.. "Score: " (- (length snake-segments) 3))))
  
