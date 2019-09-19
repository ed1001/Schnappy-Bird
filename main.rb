require 'gosu'

class GameWindow < Gosu::Window
  GRAVITY = 9.8

  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true),
      player: Gosu::Image.new('images/pixil-frame-0.png')
    }
    @game_var = {
      scroll: 0,
      player_y: (height / 2)
    }
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    end
  end

  def update
    @game_var[:scroll] -= 3
    @game_var[:scroll] = 0 if @game_var[:scroll] <= -@images[:background].width
  end

  def draw
    @images[:background].draw(@game_var[:scroll], 0, 0)
    @images[:background].draw((@game_var[:scroll] + @images[:background].width), 0, 0)
    @images[:player].draw((width / 2) - 20,  @game_var[:player_y], 0)
  end
end

window = GameWindow.new(600, 450, false)

window.show
