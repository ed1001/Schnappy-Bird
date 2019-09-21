require 'gosu'
require 'json'
require_relative 'movement'
require_relative 'game_state'

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
      player: Gosu::Image.new('images/schnappy_bird.png'),
      trail_1: Gosu::Image.new('images/trail_1_alt.png'),
      trail_2: Gosu::Image.new('images/trail_2_alt.png'),
      pipe: Gosu::Image.new('images/pipe.png'),
      coin: Gosu::Image.new('images/coin.png')
    }
    @sounds = {
      song: Gosu::Song.new('sounds/Chiba.mp3'),
      point_sound: Gosu::Sample.new('sounds/schnappy_point.mp3'),
      jump_sound: Gosu::Sample.new('sounds/schnappy_jump.mp3'),
      death_sound: Gosu::Sample.new('sounds/schnappy_death.mp3'),
      fly_off: Gosu::Sample.new('sounds/schnappy_flyoff.mp3'),
      coin_sound: Gosu::Sample.new('sounds/schnappy_coin.mp3')
    }

    @game_state = GameState.new(width, height, Pipe.new(width, rand(RANGE), false))

    @hi_score = JSON.parse(File.read('data.json'))['hi_score']
    @score_board = Gosu::Font.new(45)
    @hi_score_board = Gosu::Font.new(20)
    @game_text = Gosu::Font.new(50)
    @instruct_text = Gosu::Font.new(12)

    @last_score = 0
    @coin_countdown = 0
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      if @game_state.alive
        @game_state.p_v = -7
        @sounds[:jump_sound].play(0.2)
        if !@game_state.started
          @game_state.started = true
          @sounds[:song].play(true)
        end
      end
    end
  end

  def update
    if @game_state.alive
      # scrolling
      @game_state.scroll -= SCROLL_SPEED
      @game_state.scroll = 0 if @game_state.scroll <= -@images[:background].width
      if @game_state.started
        # player movement
        @game_state.p_v += GRAVITY
        @game_state.p_y += @game_state.p_v
        @game_state.p_ang = Movement.rotate(@game_state.p_v)
        # player animation
        @game_state.p_frame = Movement.animate(@game_state.p_v)
        # pipe movement
        @game_state.pipes << Pipe.new(width, rand(RANGE), false) if @game_state.pipes.last.x < width / 1.8
        @game_state.pipes.each do |pipe|
          collision_pipe(@game_state.p_y, pipe) if pipe.x.between?(219, 305)
          pipe.x -= PIPE_SPEED
          @game_state.pipes.delete(pipe) if pipe.x < -50
          if pipe.x < @game_state.p_x - @images[:pipe].width && pipe.passed == false
            @game_state.score += 1
            @sounds[:point_sound].play(0.2)
            pipe.passed = true
            if @coin_countdown < 0
              @game_state.coins << Coin.new(width + 50, rand(100..300))
              @coin_countdown = rand(3..10)
            end
            @coin_countdown -= 1
          end
        end
        # coin movement
        @game_state.coins.each do |coin|
          collision_coin(@game_state.p_y, coin) if coin.x.between?(256, 336)
          coin.x -= PIPE_SPEED
          @game_state.coins.delete(coin) if coin.x < -20
        end
        # check alive
        player_die unless @game_state.p_y.between?(0, 450)
      end
    else
      @game_state.restart_delay -= 1
      @game_state = GameState.new(width, height, Pipe.new(width, rand(RANGE), false)) if @game_state.restart_delay < 0
    end
  end

  def draw
    # text drawing
    @hi_score_board.draw_text("hi-score: #{@hi_score.to_i > @game_state.score ? @hi_score : @game_state.score.to_s}", 460, 15, 1)
    if @game_state.alive && !@game_state.started
      @game_text.draw_text("Schnappy Bird", 160, 120, 3)
      @instruct_text.draw_text("press space to start", 240, 300, 3)
      @hi_score_board.draw_text("last score: #{@last_score}", 460, 35, 1) if @last_score > 0
    else
      @score_board.draw_text(@game_state.score.to_s, 500, 50, 1)
    end
    # BG
    @images[:background].draw(@game_state.scroll, 0, 0)
    @images[:background].draw((@game_state.scroll + @images[:background].width), 0, 0)
    # player
    unless @game_state.alive
      @game_state.p_ang += 15
      @game_state.p_frame = :player
      @game_text.draw_text("Game Over!", 180, @game_state.game_over_y, 3)
      @game_state.game_over_v += GRAVITY / 2.5
      @game_state.game_over_y += @game_state.game_over_v unless @game_state.game_over_y > 200
    end
    @images[@game_state.p_frame].draw_rot(@game_state.p_x, @game_state.p_y, 2, @game_state.p_ang)
    # pipes
    @game_state.pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
    end
    @game_state.coins.each do |coin|
      @images[:coin].draw(coin.x, coin.y, 1)
    end
  end

  private

  def collision_pipe(player_y, pipe)
    player_die unless player_y.between?(pipe.y - GAP, pipe.y )
  end

  def collision_coin(player_y, coin)
    if player_y.between?(coin.y - @images[:player].height, coin.y + @images[:coin].height)
      @game_state.score += 1
      @sounds[:coin_sound].play(0.7)
      @game_state.coins.pop
    end
  end

  def player_die
    @game_state.alive = false
    @sounds[:death_sound].play(0.2)
    @sounds[:fly_off].play(0.2)
    @sounds[:song].stop
    @last_score = @game_state.score
    File.open('data.json', 'wb') do |file|
      file.write(JSON.generate("hi_score": @game_state.score.to_s))
    end if @game_state.score > @hi_score.to_i
  end
end

window = GameWindow.new(600, 450, false)

window.show
