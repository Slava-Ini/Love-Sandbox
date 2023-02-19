;; Constants
(local playing-area-width 300)
(local playing-area-height 388)

(local pipe-space-height 100)
(local pipe-space-min 54)
(local pipe-width 54)

(local bird-width 30)
(local bird-height 25)
(local bird-x 62)

;; State
(var bird-y 0)
(var bird-y-speed 0)

(var pipe-one-x 0)
(var pipe-one-space-y 100)
(var pipe-two-x 0)
(var pipe-two-space-y 200)
(var upcoming-pipe 1)

(var score 0)

;; -- Helper functions --
(fn get-random-pipe-y []
  (love.math.random pipe-space-min (- playing-area-height pipe-space-height)))

(fn bird-collids? [x y]
  ;; Bird's left side < x's right side
  (and (< bird-x (+ x pipe-width)) ;; Bird's right side > x's left side
       (> (+ bird-x bird-width) x) ;; Bird's bottom < y's bottom
       (or (< bird-y y) ;; Bird's top > y's top
           (> (+ bird-y bird-height) (+ y pipe-space-height)))))

(fn draw-pipe [x y]
  (love.graphics.setColor 0.37 0.82 0.28)
  (love.graphics.rectangle :fill x 0 pipe-width y)
  (love.graphics.rectangle :fill x (+ y pipe-space-height) pipe-width
                           (- playing-area-height y)))

(fn move-pipe [dt pipe-x pipe-space-y] ; (local (one tw))
  (local res-pipe-x (- pipe-x (* 60 dt)))
  (if (< (+ res-pipe-x pipe-width) 0)
      (values playing-area-width (get-random-pipe-y))
      (values res-pipe-x pipe-space-y)))

(fn update-score [this-pipe pipe-x next-pipe]
  (when (and (= upcoming-pipe this-pipe) (> bird-x (+ pipe-x pipe-width)))
    (set score (+ score 1))
    (set upcoming-pipe next-pipe)))

;; -- Love methods --
(fn love.load []
  ;; Set score
  (set score 0)
  ;; Set next pipe
  (set upcoming-pipe 1)
  ;; Set bird starting y
  (set bird-y 200)
  ;; Set pipes starting position
  (set pipe-one-x playing-area-width)
  (set pipe-two-x
       (+ playing-area-width (/ (+ playing-area-width pipe-width) 2)))
  (set pipe-one-space-y (get-random-pipe-y))
  (set pipe-two-space-y (get-random-pipe-y)))

(fn love.update [dt]
  ;; - Define bird movement
  (set bird-y-speed (+ bird-y-speed (* 516 dt)))
  (set bird-y (+ bird-y (* bird-y-speed dt)))
  ;; - Define pipe movement
  (set (pipe-one-x pipe-one-space-y) (move-pipe dt pipe-one-x pipe-one-space-y))
  (set (pipe-two-x pipe-two-space-y) (move-pipe dt pipe-two-x pipe-two-space-y))
  ;; Bird and pipe collision
  (if (or (bird-collids? pipe-one-x pipe-one-space-y)
          (bird-collids? pipe-two-x pipe-two-space-y)
          (> bird-y playing-area-height))
      (love.load))
  ;; Update score 
  (update-score 1 pipe-one-x 2)
  (update-score 2 pipe-two-x 1))

(fn love.keypressed [key]
  (if (> bird-y 0)
      (set bird-y-speed -200)))

(fn love.draw []
  ;; - Draw background
  (love.graphics.setColor 0.14 0.36 0.46)
  (love.graphics.rectangle :fill 0 0 playing-area-width playing-area-height)
  ;; - Draw "bird" rectangle
  (love.graphics.setColor 0.87 0.84 0.27)
  (love.graphics.rectangle :fill bird-x bird-y bird-width bird-height)
  ;; - Draw "pipe" rectangle
  (draw-pipe pipe-one-x pipe-one-space-y)
  (draw-pipe pipe-two-x pipe-two-space-y)
  ;; - Draw score
  (love.graphics.setColor 1 1 1)
  (love.graphics.print score 15 15))
