class GameState
  attr_accessor :scroll, :pipes, :restart_delay, :game_over_v, :game_over_y, :coins

  def initialize(pipe)
    @scroll = 0
    @pipes = [pipe]
    @score = 0
    @restart_delay = 2 * 60
    @game_over_v = 0
    @game_over_y = -50
    @coins = []
  end
end
