class GameState
  attr_accessor :scroll, :p_y, :p_x, :p_v, :p_ang, :p_frame, :pipes, :score, :alive, :restart_delay, :started, :game_over_v, :game_over_y, :coins

  def initialize(width, height, pipe)
    @scroll = 0
    @p_y = (height / 2)
    @p_x = (width / 2) - 20
    @p_v = 0
    @p_ang = 0
    @p_frame = :player
    @pipes = [pipe]
    @score = 0
    @alive = true
    @started = false
    @restart_delay = 2 * 60
    @game_over_v = 0
    @game_over_y = -50
    @coins = []
  end
end
