require 'gosu'
require 'json'
require_relative 'movement'
require_relative 'game_state'
require_relative 'player'

class GameWindow < Gosu::Window
  Pipe = Struct.new(:x, :y, :passed)
  Coin = Struct.new(:x, :y)

  SCROLL_SPEED = 2
  PIPE_SPEED = 5
  GRAVITY = 23.8 / 60
  RANGE = (150..400)
  GAP = 95

  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new('images/schnappy_bird_BG.jpg', tileable: true),
      pipe: Gosu::Image.new('images/pipe.png'),
      coin: Gosu::Image.new('images/coin.png')
    }
    @fonts = {
      score_board: Gosu::Font.new(45),
      hi_score_board: Gosu::Font.new(20),
      game_text: Gosu::Font.new(50),
      instruct_text: Gosu::Font.new(12)
    }
    # new gamestate object with starting values
    @game_state = GameState.new(width, height, Pipe.new(width, rand(RANGE), false))
    @player = Player.new
    # general variables

    @coin_countdown = 0
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
      # scrolling
      @game_state.scroll -= SCROLL_SPEED
      @game_state.scroll = 0 if @game_state.scroll <= -@images[:background].width
      if @player.started
        @player.move
        pipe_move
        coin_move
        @player.die unless @player.y.between?(0, 450)
      end
    else
      @game_state.restart_delay -= 1
      new_game if @game_state.restart_delay.negative?
    end
  end

  def draw
    draw_text
    draw_bg
    @player.draw
    draw_pipes
    draw_coins
  end

  private

  def new_game
    @game_state = GameState.new(width, height, Pipe.new(width, rand(RANGE), false))
    @player = Player.new
  end

  def pipe_move
    @game_state.pipes << Pipe.new(width, rand(RANGE), false) if @game_state.pipes.last.x < width / 1.8
    @game_state.pipes.each do |pipe|
      collision_pipe(@player.y, pipe) if pipe.x.between?(219, 305)
      pipe.x -= PIPE_SPEED
      @game_state.pipes.delete(pipe) if pipe.x < -50
      if pipe.x < @player.x - @images[:pipe].width && pipe.passed == false
        @player.score += 1
        @player.sounds[:point_sound].play(0.2)
        pipe.passed = true
        if @coin_countdown < 0
          @game_state.coins << Coin.new(width + 50, rand(100..300))
          @coin_countdown = rand(3..10)
        end
        @coin_countdown -= 1
      end
    end
  end

  def coin_move
    @game_state.coins.each do |coin|
      collision_coin(@player.y, coin) if coin.x.between?(256, 336)
      coin.x -= PIPE_SPEED
      @game_state.coins.delete(coin) if coin.x < -20
    end
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

  def draw_bg
    @images[:background].draw(@game_state.scroll, 0, 0)
    @images[:background].draw((@game_state.scroll + @images[:background].width), 0, 0)
  end

  def draw_pipes
    @game_state.pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
    end
  end

  def draw_coins
    @game_state.coins.each do |coin|
      @images[:coin].draw(coin.x, coin.y, 1)
    end
  end

  def collision_pipe(player_y, pipe)
    @player.die unless @player.y.between?(pipe.y - GAP, pipe.y)
  end

  def collision_coin(player_y, coin)
    if @player.y.between?(coin.y - @player.images[:player].height, coin.y + @images[:coin].height)
      @player.score += 1
      @player.sounds[:coin_sound].play(0.7)
      @game_state.coins.pop
    end
  end
end

window = GameWindow.new(600, 450, fullscreen: false)

window.show
