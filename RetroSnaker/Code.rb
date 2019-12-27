def initGame
    $snake = Sprite.new
    $snake.bitmap = Bitmap.new("Graphics/Pictures/Circle")
    $snake.bitmap.hue_change(90)
    $snake.zoom_x = 0.1
    $snake.zoom_y = 0.1
    $snake.ox = $snake.bitmap.width / 2
    $snake.oy = $snake.bitmap.height / 2
    $snake.x = 10 * $snake.bitmap.width * $snake.zoom_x + $snake.ox * $snake.zoom_x
    $snake.y = 8 * $snake.bitmap.height * $snake.zoom_y + $snake.oy * $snake.zoom_y
    $snake_body = [$snake]
    $snake_length = 5
    $step = $snake.bitmap.width * $snake.zoom_x
    
    $target = Sprite.new
    $target.bitmap = Bitmap.new("Graphics/Pictures/Circle")
    $target.zoom_x = 0.1
    $target.zoom_y = 0.1
    $target.ox = $snake.bitmap.width / 2
    $target.oy = $snake.bitmap.height / 2
    $target.x = -1 * $snake.bitmap.width * $snake.zoom_x + $snake.ox
    $target.y = -1 * $snake.bitmap.height * $snake.zoom_y + $snake.oy
    
    $score = 0
    $score_text = Sprite.new
    $score_text.bitmap = Bitmap.new(640, 30)
    $score_text.bitmap.draw_text(0, 0, 640, 30, "Score:"+$score.to_s)
    $state_text = Sprite.new
    $state_text.y = 30
    $state_text.bitmap = Bitmap.new(640, 30)
    $state_text.bitmap.draw_text(0, 0, 640, 30, "Pause(Press C to continue)")
    
    for i in 1..$snake_length
      $snake_body.push(Sprite.new)
      $snake_body[i].bitmap = Bitmap.new("Graphics/Pictures/Circle")
      $snake_body[i].zoom_x = 0.1
      $snake_body[i].zoom_y = 0.1
      $snake_body[i].ox = $snake.ox
      $snake_body[i].oy = $snake.ox
      $snake_body[i].x = $snake_body[i-1].x - $snake.bitmap.width * $snake.zoom_x
      $snake_body[i].y = $snake.y
    end
    
    $direction = 1
    $timer = 0
    $time_window = 5
    $game_state = 0
  end
  
  initGame
  
  def generateTarget
    rx = rand(640/$snake.bitmap.width/$snake.zoom_x).to_i * $snake.bitmap.width * $snake.zoom_x + $snake.ox * $snake.zoom_x
    ry = rand(480/$snake.bitmap.height/$snake.zoom_y).to_i * $snake.bitmap.height * $snake.zoom_y + $snake.oy * $snake.zoom_y
    $target.x = rx
    $target.y = ry
  end
  
  generateTarget
  
  def eatCheck
    if ($target.x - $snake.x).abs < $snake.bitmap.width * $snake.zoom_x and ($target.y - $snake.y).abs < $snake.bitmap.height * $snake.zoom_y
      generateTarget
      $score += 1
      $score_text.bitmap.dispose
      $score_text.bitmap = Bitmap.new(640, 30)
      $score_text.bitmap.draw_text(0, 0, 640, 30, "Score:"+$score.to_s)
      $snake_body.push(Sprite.new)
      $snake_body[$snake_length].bitmap = Bitmap.new("Graphics/Pictures/Circle")
      $snake_body[$snake_length].zoom_x = 0.1
      $snake_body[$snake_length].zoom_y = 0.1
      $snake_body[$snake_length].ox = $snake.ox
      $snake_body[$snake_length].oy = $snake.ox
      $snake_body[$snake_length].x = $snake_body[$snake_length-1].x
      $snake_body[$snake_length].y = $snake_body[$snake_length-1].y
      $snake_length += 1
    end
  end
  
  def bounderyCheck
    if $snake.x >= 640
      return false
    end
    if $snake.x <= 0
      return false
    end
    if $snake.y >= 480
      return false
    end
    if $snake.y <= 0
      return false
    end
    return true
  end
  
  def selfCollisionCheck
    for i in 1..$snake_length
      if ($snake_body[i].x-$snake.x).abs < $snake.ox*$snake.zoom_x and ($snake_body[i].y-$snake.y).abs < $snake.oy*$snake.zoom_y
        gameOver
        break
      end
    end
  end
  
  def bodyMove
    for i in 1..$snake_length
      $snake_body[$snake_length+1-i].x = $snake_body[$snake_length-i].x
      $snake_body[$snake_length+1-i].y = $snake_body[$snake_length-i].y
    end
  end
  
  def move
    if $direction == 0
      return
    end
    if $direction == 1
      $snake.x += $step
      if (!bounderyCheck)
        $snake.x -= $step
        $direction = 0
        gameOver
        return
      end
      $snake.x -= $step
      bodyMove
      $snake.x += $step
    end
    if $direction == -1
      $snake.x -= $step
      if (!bounderyCheck)
        $snake.x += $step
        $direction = 0
        gameOver
        return
      end
      $snake.x += $step
      bodyMove
      $snake.x -= $step
    end
    if $direction == 2
      $snake.y += $step
      if (!bounderyCheck)
        $snake.y -= $step
        $direction = 0
        gameOver
        return
      end
      $snake.y -= $step
      bodyMove
      $snake.y += $step
    end
    if $direction == -2
      $snake.y -= $step
      if (!bounderyCheck)
        $snake.y += $step
        $direction = 0
        gameOver
        return
      end
      $snake.y += $step
      bodyMove
      $snake.y -= $step
    end
  end
  
  def update
    if Input.trigger?(Input::C)
      if $game_state == 0
        $game_state = 1
        $state_text.bitmap.dispose
      elsif $game_state == 1
        $game_state = 0
        $state_text.bitmap = Bitmap.new(640, 30)
        $state_text.bitmap.draw_text(0, 0, 640, 30, "Pause(Press C to continue)")
      end
    end
    if $game_state == 1
      if Input.trigger?(Input::RIGHT)
        if $direction != -1
          $direction = 1
        end
      end
      if Input.trigger?(Input::LEFT)
        if $direction != 1
          $direction = -1
        end
      end
      if Input.trigger?(Input::DOWN)
        if $direction != -2
          $direction = 2
        end
      end
      if Input.trigger?(Input::UP)
        if $direction != 2
          $direction = -2
        end
      end
      if $timer == 0
        move
        selfCollisionCheck
        eatCheck
      end
      if $timer != $time_window
        $timer += 1
      else
        $timer = 0
      end
    end
  end
  
  def gameOver
    $state_text.dispose
    $score_text.dispose
    for i in $snake_body
      i.dispose
    end
    $target.dispose
    initGame
  end
  
  loop do
    Graphics.update
    Input.update
    update
  end
  