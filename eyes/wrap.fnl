;; --- Helper functions
(fn draw-eye [x y]
  (local distance-x (- (love.mouse.getX) x))
  (local distance-y (- (love.mouse.getY) y))
  ;; - Use Pythagorean theorem to get the distance between the mouse and the eye,
  ;;   but limit the distance to 30 so the pupil doesn't go outside the eye
  (local distance (math.min (math.sqrt (+ (* distance-x distance-x) (* distance-y distance-y))) 30))
  ;; - Use the arctangent to get the angle between the mouse and the eye in radians
  (local angle (math.atan2 distance-y distance-x))

  ;; - Debug print
  ; (local coordinates [(.. "distance x: " distance-x) (.. "distance y: " distance-y) (.. "distance: " distance) (.. "angle: " angle) (.. "cos(angle): " (math.cos angle)) (.. "sin(angle): " (math.sin angle))])
  
  ; (when (= x 70)
  ;   (love.graphics.setColor 1 1 1)
  ;   (love.graphics.print (table.concat coordinates "\n")))


  ;; - Use the cosine and sine of the angle to get the x and y coordinates of the pupil
  (local pupil-x (+ x (* (math.cos angle) distance)))
  (local pupil-y (+ y (* (math.sin angle) distance)))

  (love.graphics.setColor 1 1 1)
  (love.graphics.circle :fill x y 50)

  (love.graphics.setColor 0 0 0.4)
  (love.graphics.circle :fill pupil-x pupil-y 15))

;; --- Love methods
(fn love.load [])

(fn love.update [dt])

(fn love.keypressed [key])

(fn love.draw []
  (draw-eye 70 200)
  (draw-eye 200 200))
