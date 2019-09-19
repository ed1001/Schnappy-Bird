require 'gosu'
require_relative 'movement'

class GameWindow < Gosu::Window
  GRAVITY = 23.8 / 60

  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true),
      player: Gosu::Image.new('images/schnappy_bird.png'),
      trail_1:  Gosu::Image.new('images/trail_1_alt.png'),
      trail_2:  Gosu::Image.new('images/trail_2_alt.png'),
      pipe: Gosu::Image.new('images/pipe.png')
    }
    @jump_sound = Gosu::Sample.new('sounds/62_ClapOneShot.wav')
    @game_var = {
      scroll: 0
    }
    @player_var = {
      y: (height / 2),
      velocity_y: 0,
      angle: 0
    }
    @player_frame = :player
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      @player_var[:velocity_y] = -7
      @jump_sound.play
    end
  end

  def update
    @game_var[:scroll] -= 3
    @game_var[:scroll] = 0 if @game_var[:scroll] <= -@images[:background].width
    @player_var[:velocity_y] += GRAVITY
    @player_var[:y] += @player_var[:velocity_y]
    @player_var[:angle] = Movement.rotate(@player_var[:velocity_y])
    @player_frame = Movement.animate(@player_var[:velocity_y])
  end

  def draw
    @images[:background].draw(@game_var[:scroll], 0, 0)
    @images[:background].draw((@game_var[:scroll] + @images[:background].width), 0, 0)
    @images[@player_frame].draw_rot((width / 2) - 20, @player_var[:y], 0, @player_var[:angle])
    @images[:pipe].draw(0, 0, 0)
  end
end

window = GameWindow.new(600, 450, false)

window.show
