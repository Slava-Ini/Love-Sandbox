; Constants
(local playing-area-width 300)
(local playing-area-height 388)

(local pipe-space-height 100)
(local pipe-space-min 54)
(local pipe-width 54)

(local bird-width 30)
(local bird-height 25)
(local bird-x 62)

; State
(var bird-y 0)
(var bird-y-speed 0)

(var pipe-one-x 0)
(var pipe-one-space-y 100)
(var pipe-two-x 0)
(var pipe-two-space-y 100)

; -- Helper functions --
(fn get-random-pipe-y []
  (love.math.random pipe-space-min (- playing-area-height pipe-space-height)))

(fn reset-pipe []
  (set pipe-one-x playing-area-width)
  (set pipe-two-x (+ playing-area-width (/ (+ playing-area-width pipe-width) 2))))

; Can be improved vastly
(fn bird-colliding? [x y]
  ; Bird's left side < x's right side
  (and (< bird-x (+ x pipe-width))
  ; Bird's right side > x's left side
       (> (+ bird-x bird-width) x)
  ; Bird's bottom < y's bottom
       (or (< bird-y y)
  ; Bird's top > y's top
           (> (+ bird-y bird-height) (+ y pipe-space-height)))))

(fn draw-pipe [x y]
  (love.graphics.setColor 0.37 0.82 0.28)
  (love.graphics.rectangle :fill x 0 pipe-width y)
  (love.graphics.rectangle :fill x (+ y pipe-space-height) pipe-width (- playing-area-height y)))
   

; -- Love methods --
(fn love.load []
  (set bird-y 200)
  (set pipe-one-space-y (get-random-pipe-y))
  (set pipe-two-space-y (get-random-pipe-y))
  (reset-pipe))

(fn love.update [dt]
  ; - Define bird movement
  (set bird-y-speed (+ bird-y-speed (* 516 dt)))
  (set bird-y (+ bird-y (* bird-y-speed dt)))
  ; - Define pipe movement
  (set pipe-one-x (- pipe-one-x (* 60 dt)))
  (set pipe-two-x (- pipe-two-x (* 60 dt)))

  ; Re-draw a pipe when go out of screen
  ; TODO: first fix this bug, and then do optimizations
  (if (or (< (+ pipe-one-x pipe-width) 0)
          (< (+ pipe-two-x pipe-width) 0))
    (reset-pipe))

  ; Bird and pipe collision
  (if (or (bird-colliding? pipe-one-x pipe-one-space-y)
          (bird-colliding? pipe-two-x pipe-two-space-y)
          (> bird-y playing-area-height))
    (love.load)))

(fn love.keypressed [key]
  (if (> bird-y 0)
      (set bird-y-speed -200)))

(fn love.draw []
  ; - Draw background
  (love.graphics.setColor 0.14 0.36 0.46)
  (love.graphics.rectangle :fill 0 0 playing-area-width playing-area-height)
  ; - Draw "bird" rectangle
  (love.graphics.setColor 0.87 0.84 0.27)
  (love.graphics.rectangle :fill bird-x bird-y bird-width bird-height)
  ; - Draw "pipe" rectangle
    (draw-pipe pipe-one-x pipe-one-space-y)
    (draw-pipe pipe-two-x pipe-two-space-y))
