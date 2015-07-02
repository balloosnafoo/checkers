
class Piece
  attr_reader :color

  def initialize(color, board, pos)
    @color  = color
    @board  = board
    @pos    = pos
    @kinged = kinged
    @direction = color == :black ? 1 : -1
  end

  JUMPING_VECTORS = [[2, 2], [2, -2]]

  def jumping_moves

  end

  SLIDING_VECTORS = [[1, 1], [1, -1]]

  def sliding_moves
    x, y = pos
    SLIDING_VECTORS.each_with_object([]) do |vector, arr|
      dx, dy = vector.map{ |v| v * direction }
      to_pos = [x + dx, y + dy]
      arr << to_pos if board.empty_square?(to_pos) && board.on_board?(to_pos)

      if king?
        dx, dy = vector.map{ |v| v * -direction }
        to_pos = [x + dx, y + dy]
        arr << to_pos if board.empty_square?(to_pos) && board.on_board?(to_pos)
      end
    end
  end

  def king?
    kinged
  end

  def empty?
    false
  end

  def to_s
    (kinged ? " \u2622 " : " \u263B ").colorize(color)
  end

  def inspect
    "#{color} #{pos}"
  end

  private
  attr_reader :kinged, :pos, :direction, :board

end
