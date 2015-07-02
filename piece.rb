
class Piece
  attr_reader :color

  def initialize(color, board, pos)
    @color  = color
    @pos    = pos
    @kinged = kinged
  end

  def jumping_moves
  end

  def sliding_moves
  end

  def king?
    kinged
  end

  def to_s
    (kinged ? " \u2622 " : " \u263B ").colorize(color)
  end

  def inspect
    "#{color} #{pos}"
  end

  private
  attr_reader :kinged, :pos

end
