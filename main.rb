# frozen_string_literal: true

require 'gosu'
require 'json'
require_relative 'player'
require_relative 'environment'
require_relative 'text'

class GameWindow < Gosu::Window
  def initialize
    super 600, 450, fullscreen: false

    @restart_delay = 120
    @player = Player.new
    @environment = Environment.new(width)
    @text = Text.new
  end

  def button_down(btn)
    super

    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      @player.jump
    when Gosu::KB_F
      self.fullscreen = !fullscreen?
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
    @player.draw
    @environment.draw_bg
    @environment.draw_pipes
    @environment.draw_coins
    @text.draw(@player)
  end

  private

  def new_game
    @restart_delay = 120
    @player = Player.new(@player.last_score)
    @environment = Environment.new(width)
    @text = Text.new
  end
end

window = GameWindow.new

window.show
