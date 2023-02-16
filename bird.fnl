(var bird-y 0)
(var bird-y-speed 0)
(var playing-area-width 0)
(var playing-area-height 0)

(fn love.load []
  (set bird-y 200)
  (set playing-area-width 300)
  (set playing-area-height 388))

(fn love.update [dt]
  (set bird-y-speed (+ bird-y-speed (* 516 dt)))
  (set bird-y (+ bird-y (* bird-y-speed dt))))

(fn love.keypressed [key]
  (if (> bird-y 0)
      (set bird-y-speed -200)))

(fn love.draw []
  ;; Draw background
  (love.graphics.setColor 0.14 0.36 0.46)
  (love.graphics.rectangle :fill 0 0 playing-area-width playing-area-height)
  ;; Draw "bird" rectangle
  (love.graphics.setColor 0.87 0.84 0.27)
  (love.graphics.rectangle :fill 62 bird-y 30 25)
  ;; Draw "pipe" rectangle
  (let [pipe-width 54
        pipe-space-height 100
        pipe-space-y 150]
    (love.graphics.setColor 0.37 0.82 0.28)
    (love.graphics.rectangle :fill playing-area-width 0 pipe-width pipe-space-y)
    (love.graphics.rectangle :fill playing-area-width
                             (+ pipe-space-y pipe-space-height) pipe-width
                             (- playing-area-height pipe-space-y
                                pipe-space-height))))
