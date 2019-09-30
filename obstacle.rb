require_relative 'coin'

class Obstacle
  Pipe = Struct.new(:x, :y, :passed)

  PIPE_SPEED = 5
  RANGE = (150..400)
  SPACING = 334
  GAP = 95

  def initialize
    @image = Gosu::Image.new('images/pipe.png')
    @pipes = [Pipe.new(width, rand(RANGE), false)]
  end

  def pipe_move(player, coin)
    @pipes << Pipe.new(width, rand(RANGE), false) if @pipes.last.x < SPACING
    @pipes.each do |pipe|
      collision(player.y, pipe) if pipe.x.between?(219, 305)
      pipe.x -= PIPE_SPEED
      @pipes.delete(pipe) if pipe.x < -50
      if pipe.x < player.x - @image.width && pipe.passed == false
        player.score += 1
        player.sounds[:point_sound].play(0.2)
        pipe.passed = true
        if coin.coin_countdown < 0
          coin.coins << Coin.new(width + 50, rand(100..300))
          coin.coin_countdown = rand(3..10)
        end
        coin.coin_countdown -= 1
      end
    end
  end
end


