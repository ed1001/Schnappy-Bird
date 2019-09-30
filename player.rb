require 'gosu'

class Player
  attr_reader :alive, :started, :score, :hi_score, :last_score, :sounds, :x, :y, :images
  attr_writer :score

  GRAVITY = 23.8 / 60

  def initialize
    @images = {
      player: Gosu::Image.new('images/schnappy_bird.png'),
      trail_1: Gosu::Image.new('images/trail_1_alt.png'),
      trail_2: Gosu::Image.new('images/trail_2_alt.png'),
    }
    @sounds = {
      point_sound: Gosu::Sample.new('sounds/schnappy_point.mp3'),
      jump_sound: Gosu::Sample.new('sounds/schnappy_jump.mp3'),
      death_sound: Gosu::Sample.new('sounds/schnappy_death.mp3'),
      fly_off: Gosu::Sample.new('sounds/schnappy_flyoff.mp3'),
      coin_sound: Gosu::Sample.new('sounds/schnappy_coin.mp3'),
      song: Gosu::Song.new('sounds/Chiba.mp3')
    }
    @y = 225
    @x = 280
    @v = @angle = @score = @last_score = 0
    @frame = :player
    @alive = true
    @started = false
    @hi_score = JSON.parse(File.read('data.json'))['hi_score']
  end

  def move
    @v += GRAVITY
    @y += @v
    @angle = rotate(@v)
    @frame = animate(@v)
  end

  def jump
    return unless @alive

    @v = -7
    @sounds[:jump_sound].play(0.2)

    unless @started
      @started = true
      @sounds[:song].play(true)
    end
  end

  def draw
    unless @alive
      @angle += 15
      @frame = :player
    end
    @images[@frame].draw_rot(@x, @y, 2, @angle)
  end

  def die
    @alive = false
    @sounds[:death_sound].play(0.2)
    @sounds[:fly_off].play(0.2)
    @sounds[:song].stop
    @last_score = @score
    if @score > @hi_score.to_i
      @hi_score = @score
      File.open('data.json', 'wb') do |file|
        file.write(JSON.generate("hi_score": @score.to_s))
      end
    end
  end

  private

  def rotate(velocity)
    case
    when velocity.negative?
      330
    when velocity.between?(0, 5)
      0
    when velocity.between?(5, 8)
      15
    when velocity.between?(8, 12)
      25
    when velocity.between?(12, 15)
      30
    when velocity > 15
      80
    end
  end

  def animate(velocity)
    case
    when velocity < -3
      :trail_2
    when velocity.between?(-3, -1)
      :trail_1
    when velocity.between?(-1, 8)
      :player
    when velocity.between?(8, 12)
      :trail_1
    when velocity > 12
      :trail_2
    end
  end
end
