
class Piece
  attr_reader :color

  def initialize(color, pos)
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

  private
  attr_reader :kinged

end
