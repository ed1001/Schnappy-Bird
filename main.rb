require 'gosu'
require 'json'
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
    @sounds = {
      song: Gosu::Song.new('sounds/Chiba.mp3'),
      point_sound: Gosu::Sample.new('sounds/schnappy_point.mp3'),
      jump_sound: Gosu::Sample.new('sounds/schnappy_jump.mp3'),
      death_sound: Gosu::Sample.new('sounds/schnappy_death.mp3'),
      fly_off: Gosu::Sample.new('sounds/schnappy_flyoff.mp3')
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
    @hi_score = JSON.parse(File.read('data.json'))['hi_score']
    @score_board = Gosu::Font.new(45)
    @hi_score_board = Gosu::Font.new(20)
    @alive = true
    @angle = 0
    @sounds[:song].play
  end

  def button_down(btn)
    super
    case btn
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      @player_var[:velocity_y] = -7
      @sounds[:jump_sound].play(0.2)
    end
  end

  def update
    if @alive
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
          @sounds[:point_sound].play(0.2)
          pipe.passed = true
        end
      end
      player_die unless @player_var[:y].between?(0, 450)
    end
  end

  def draw
    # score board
    @score_board.draw_text(@score.to_s, 500, 50, 1)
    @hi_score_board.draw_text("hi-score: #{@hi_score.to_i > @score ? @hi_score : @score.to_s}", 480, 15, 1)
    # BG
    @images[:background].draw(@game_var[:scroll], 0, 0)
    @images[:background].draw((@game_var[:scroll] + @images[:background].width), 0, 0)
    # player
    unless @alive
      @player_var[:angle] += 15
      @player_frame = :player
    end
    @images[@player_frame].draw_rot(@player_var[:x], @player_var[:y], 2, @player_var[:angle])
    # pipes
    @pipes.each do |pipe|
      @images[:pipe].draw(pipe.x, pipe.y, 0)
      @images[:pipe].draw_rot(pipe.x, pipe.y - GAP, 0, 180, 1, 0)
      collision_pipe(@player_var[:y], pipe) if pipe.x.between?(219, 305) && @alive
    end
  end

  private

  def collision_pipe(player_y, pipe)
    player_die unless player_y.between?(pipe.y - GAP, pipe.y)
  end

  def player_die
    @alive = false
    @sounds[:death_sound].play(0.2)
    @sounds[:fly_off].play(0.2)
    @sounds[:song].stop
    File.open('data.json', 'wb') do |file|
      file.write(JSON.generate("hi_score": @score.to_s))
    end if @score > @hi_score.to_i
  end
end

window = GameWindow.new(600, 450, false)

window.show
