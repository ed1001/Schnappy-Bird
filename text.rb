# frozen_string_literal: true

class Text
  TEXT_GRAVITY = 10.0 / 60

  def initialize
    @fonts = {
      score_board: Gosu::Font.new(45),
      hi_score_board: Gosu::Font.new(20),
      game_text: Gosu::Font.new(50),
      instruct_text: Gosu::Font.new(12)
    }
    @game_over_velocity = 0
    @game_over_y = -@fonts[:game_text].height
  end

  def draw(player)
    hi_score(player)

    if player.alive
      player.started ? @fonts[:score_board].draw_text(player.score.to_s, 500, 50, 1) : pre_game(player)
    else
      draw_game_over
    end
  end

  private

  def hi_score(player)
    @fonts[:hi_score_board].draw_text("hi-score: #{player.hi_score.to_i > player.score ? player.hi_score : player.score.to_s}", 460, 15, 1)
  end

  def pre_game(player)
    @fonts[:game_text].draw_text('Schnappy Bird', 160, 120, 3)
    @fonts[:instruct_text].draw_text('press space to start', 240, 300, 3)
    @fonts[:hi_score_board].draw_text("last score: #{player.last_score}", 460, 35, 1) if player.last_score.positive?
  end

  def draw_game_over
    @fonts[:game_text].draw_text('Game Over!', 180, @game_over_y, 3)
    @game_over_velocity += TEXT_GRAVITY
    @game_over_y += @game_over_velocity unless @game_over_y > 200
  end
end
