class Movement
  def self.rotate(velocity)
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

  def self.animate(velocity)
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
