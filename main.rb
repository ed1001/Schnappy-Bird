require 'gosu'
require_relative 'movement'

class GameWindow < Gosu::Window
  Pipe = Struct.new(:x, :y, :passed)
  Rect = Struct.new(:x, :y, :w, :h)

  SCROLL_SPEED = 2
  PIPE_SPEED = 4
  GRAVITY = 23.8 / 60
  RANGE = (150..400)
  GAP = 95

  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true),
      player: Gosu::Image.new('images/schnappy_bird.png'),
      trail_1: Gosu::Image.new('images/trail_1_alt.png'),
      trail_2: Gosu::Image.new('images/trail_2_alt.png'),
      pipe: Gosu::Image.new('images/pipe.png')
    }
    @game_var = {
      scroll: 0
    }
    @player_var = {
      y: (height / 2),
      x: (width / 2) - 20,
      velocity_y: 0,
      angle: 0
    }
    @player_frame = :player
    @pipes = [Pipe.new(width, rand(RANGE), false)]
    @bird_hb = Rect.new
    @score = 0
    @score_board = Gosu::Font.new(45)
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      @player_var[:velocity_y] = -7
    end
  end

  def update
    # scrolling
    @game_var[:scroll] -= SCROLL_SPEED
    @game_var[:scroll] = 0 if @game_var[:scroll] <= -@images[:background].width
    # player movement
    @player_var[:velocity_y] += GRAVITY
    @player_var[:y] += @player_var[:velocity_y]
    @player_var[:angle] = Movement.rotate(@player_var[:velocity_y])
    # player animation
    @player_frame = Movement.animate(@player_var[:velocity_y])
    # pipe movement
    @pipes << Pipe.new(width, rand(RANGE), false) if @pipes.last.x < width / 1.8
    @pipes.each do |pipe|
      pipe.x -= PIPE_SPEED
      @pipes.delete(pipe) if pipe.x < -50
      if pipe.x < @player_var[:x] - @images[:pipe].width && pipe.passed == false
        @score += 1
        pipe.passed = true
        p @score
      end
    end
  end

  def draw
    # score board
    @score_board.draw_text(@score.to_s, 50, 50, 1)
    # BG
    @images[:background].draw(@game_var[:scroll], 0, 0)
    @images[:background].draw((@game_var[:scroll] + @images[:background].width), 0, 0)
    # player
    @images[@player_frame].draw_rot(@player_var[:x], @player_var[:y], 0, @player_var[:angle])
    # pipes
    @pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
      collision(@player_var[:y], pipe) if pipe.x.between?(219, 305)
    end
  end

  private

  def collision(player_y, pipe)
    close unless player_y.between?(pipe.y - GAP, pipe.y)
  end
end

window = GameWindow.new(600, 450, false)

window.show
