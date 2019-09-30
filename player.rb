# frozen_string_literal: true

require 'gosu'

class Player
  attr_reader :alive, :started, :hi_score, :last_score, :sounds, :x, :y, :images
  attr_accessor :score

  GRAVITY = 23.8 / 60

  def initialize(last_score = 0)
    @images = {
      player: Gosu::Image.new('images/bird.png'),
      trail_1: Gosu::Image.new('images/trail_1_alt.png'),
      trail_2: Gosu::Image.new('images/trail_2_alt.png')
    }
    @sounds = {
      point: Gosu::Sample.new('sounds/schnappy_point.mp3'),
      jump: Gosu::Sample.new('sounds/schnappy_jump.mp3'),
      death: Gosu::Sample.new('sounds/schnappy_death.mp3'),
      spin: Gosu::Sample.new('sounds/schnappy_flyoff.mp3'),
      coin: Gosu::Sample.new('sounds/schnappy_coin.mp3'),
      song: Gosu::Song.new('sounds/Chiba.mp3')
    }
    @y = 225
    @x = 280
    @velocity = @angle = @score = 0
    @last_score = last_score
    @frame = :player
    @alive = true
    @started = false
    @hi_score = JSON.parse(File.read('data.json'))['hi_score']
  end

  def move
    @velocity += GRAVITY
    @y += @velocity
    @angle = rotate(@velocity)
    @frame = animate(@velocity)
  end

  def jump
    return unless @alive

    @velocity = -7
    @sounds[:jump].play(0.2)

    return if @started

    @started = true
    @sounds[:song].play(true)
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
    @sounds[:death].play(0.2)
    @sounds[:spin].play(0.2)
    @sounds[:song].stop
    @last_score = @score

    return unless @score > @hi_score.to_i

    @hi_score = @score
    File.open('data.json', 'wb') do |file|
      file.write(JSON.generate("hi_score": @score.to_s))
    end
  end

  private

  def rotate(velocity)
    if velocity.negative?
      330
    elsif velocity.between?(0, 5)
      0
    elsif velocity.between?(5, 8)
      15
    elsif velocity.between?(8, 12)
      25
    elsif velocity.between?(12, 15)
      30
    elsif velocity > 15
      80
    end
  end

  def animate(velocity)
    if velocity < -3
      :trail_2
    elsif velocity.between?(-3, -1)
      :trail_1
    elsif velocity.between?(-1, 8)
      :player
    elsif velocity.between?(8, 12)
      :trail_1
    elsif velocity > 12
      :trail_2
    end
  end
end
