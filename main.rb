require 'gosu'
require_relative 'movement'

class GameWindow < Gosu::Window
  GRAVITY = 23.8 / 60
  Pipe = Struct.new(:x, :y)
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
      velocity_y: 0,
      angle: 0
    }
    @player_frame = :player
    @pipes = [Pipe.new(width, rand(RANGE))]
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
    @game_var[:scroll] -= 2
    @game_var[:scroll] = 0 if @game_var[:scroll] <= -@images[:background].width
    # player movement
    @player_var[:velocity_y] += GRAVITY
    @player_var[:y] += @player_var[:velocity_y]
    @player_var[:angle] = Movement.rotate(@player_var[:velocity_y])
    # player animation
    @player_frame = Movement.animate(@player_var[:velocity_y])
    # pipe movement
    @pipes << Pipe.new(width, rand(RANGE)) if @pipes.last.x < width / 1.8
    @pipes.each do |pipe|
      pipe.x -= 3
      @pipes.delete(pipe) if pipe.x < -50
    end
  end

  def draw
    # BG
    @images[:background].draw(@game_var[:scroll], 0, 0)
    @images[:background].draw((@game_var[:scroll] + @images[:background].width), 0, 0)
    # player
    @images[@player_frame].draw_rot((width / 2) - 20, @player_var[:y], 0, @player_var[:angle])
    # pipes
    @pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
    end
    # @images[:pipe].draw_rot(0, 200, 0, 180, 1, 0)
  end
end

window = GameWindow.new(600, 450, false)

window.show
