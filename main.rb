require 'gosu'
require 'json'
require_relative 'player'
require_relative 'environment'

class GameWindow < Gosu::Window
  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true)
    }
    @fonts = {
      score_board: Gosu::Font.new(45),
      hi_score_board: Gosu::Font.new(20),
      game_text: Gosu::Font.new(50),
      instruct_text: Gosu::Font.new(12)
    }

    @restart_delay = 120

    @player = Player.new
    @environment = Environment.new(width)
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      @player.jump
    end
  end

  def update
    if @player.alive
      @environment.scroll
      if @player.started
        @player.move
        @environment.pipe_move(@player)
        @environment.coin_move(@player)
        @player.die unless @player.y.between?(0, 450)
      end
    else
      @restart_delay -= 1
      new_game if @restart_delay.negative?
    end
  end

  def draw
    draw_text
    @environment.draw_bg
    @player.draw
    @environment.draw_pipes
    @environment.draw_coins
  end

  private

  def new_game
    @restart_delay = 120
    @player = Player.new
    @environment = Environment.new(width)
  end

  def draw_text
    @fonts[:hi_score_board].draw_text("hi-score: #{@player.hi_score.to_i > @player.score ? @player.hi_score : @player.score.to_s}", 460, 15, 1)
    if @player.alive && !@player.started
      @fonts[:game_text].draw_text("Schnappy Bird", 160, 120, 3)
      @fonts[:instruct_text].draw_text("press space to start", 240, 300, 3)
       @fonts[:hi_score_board].draw_text("last score: #{@player.last_score}", 460, 35, 1) if @player.last_score > 0
    else
       @fonts[:score_board].draw_text(@player.score.to_s, 500, 50, 1)
    end
  end
end

window = GameWindow.new(600, 450, fullscreen: false)

window.show
