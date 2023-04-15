;; --- Constants
(local grid-x-count 20)
(local grid-y-count 15)
(local cell-size 25)
(local around {:left [-1 0] :right [1 0] :up [0 -1] :down [0 1]})

;; --- State
(var snake-segments [{ :x 3 :y 1 } { :x 2 :y 1 } { :x 1 :y 1 }])
(var snake-direction :right)
(var timer 0)

;; --- Love methods
(fn love.load [])

(fn love.update [dt]
  (set timer (+ timer dt))

  (when (>= timer 0.15)
    (set timer 0)

    (let [[around-x around-y] (. around snake-direction)] 
      (local next-x-position (-> snake-segments (. 1) (. :x) (+ around-x)))
      (local next-y-position (-> snake-segments (. 1) (. :y) (+ around-y)))
      
      (table.insert snake-segments 1 { :x next-x-position :y next-y-position })
      (table.remove snake-segments))))

(fn love.keypressed [key]
   (when (and
     (or (= key "left") (= key "right") (= key "up") (= key "down"))
     (not (match [snake-direction key]
             [:left :right] true
             [:right :left] true
             [:up :down] true
             [:down :up] true
             _ false)))
       (set snake-direction key)))

(fn love.draw []
  (love.graphics.setColor 0.28 0.28 0.28)
  (love.graphics.rectangle :fill 0 0 (* grid-x-count cell-size) (* grid-y-count cell-size))

  (each [index segment (ipairs snake-segments)]
    (love.graphics.setColor 0.6 1 0.32)
    (love.graphics.rectangle :fill
      (-> segment (. :x) (- 1) (* cell-size))
      (-> segment (. :y) (- 1) (* cell-size))
      (- cell-size 1)
      (- cell-size 1))))
  
