require 'gosu'

class Environment
  Pipe = Struct.new(:x, :y, :passed)
  Coin = Struct.new(:x, :y)

  SCROLL_SPEED = 2
  PIPE_SPEED = 5
  RANGE = (150..400)
  SPACING = 334
  GAP = 95

  def initialize(width)
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true),
      pipe: Gosu::Image.new('images/pipe.png'),
      coin: Gosu::Image.new('images/coin.png')
    }
    @pipes = [Pipe.new(width, rand(RANGE), false)]
    @coins = []
    @coin_countdown = @scroll = 0
    @screen_width = width
  end

  def scroll
    @scroll -= SCROLL_SPEED
    @scroll = 0 if @scroll <= -@images[:background].width
  end

  def pipe_move(player)
    @pipes << Pipe.new(@screen_width, rand(RANGE), false) if @pipes.last.x < SPACING
    @pipes.each do |pipe|
      collision(player, pipe) if pipe.x.between?(219, 305)
      pipe.x -= PIPE_SPEED
      @pipes.delete(pipe) if pipe.x < -@images[:pipe].width

      next unless pipe.x < player.x - @images[:pipe].width && !pipe.passed

      player.score += 1
      player.sounds[:point_sound].play(0.2)
      pipe.passed = true
      if @coin_countdown.negative?
        p @coins
        @coins << Coin.new(@screen_width + 50, rand(100..300))
        @coin_countdown = rand(3..10)
      end
      @coin_countdown -= 1
    end
  end

  def coin_move(player)
    @coins.each do |coin|
      collect_coin(player) if coin.x.between?(256, 336)
      coin.x -= PIPE_SPEED
      @coins.delete(coin) if coin.x < -20
    end
  end

  def draw_bg
    @images[:background].draw(@scroll, 0, 0)
    @images[:background].draw((@scroll + @images[:background].width), 0, 0)
  end

  def draw_pipes
    @pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
    end
  end

  def draw_coins
    @coins.each do |coin|
      @images[:coin].draw(coin.x, coin.y, 1)
    end
  end

  private

  def collision(player, pipe)
    player.die unless player.y.between?(pipe.y - GAP, pipe.y)
  end

  def collect_coin(player)
    return unless coin_collided?(player)

    player.score += 1
    player.sounds[:coin_sound].play(0.7)
    @coins.pop
  end

  def coin_collided?(player)
    player.y.between?(@coins.first.y - player.images[:player].height, @coins.first.y + @images[:coin].height)
  end
end
