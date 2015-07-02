
class Piece
  attr_reader :color

  def initialize(color, board, pos, kinged = false)
    @color  = color
    @board  = board
    @pos    = pos
    @kinged = kinged
    @direction = color == :black ? 1 : -1
  end

  JUMPING_VECTORS = [[2, 2], [2, -2]]

  def jumping_moves
    x, y = pos
    JUMPING_VECTORS.each_with_object([]) do |vector, arr|
      dx, dy = vector.map{ |v| v * direction }
      cap_x, cap_y = vector.map{ |v| v * direction  / 2 }
      to_pos = [x + dx, y + dy]
      cap_pos = [x + cap_x, y + cap_y]
      if board.empty_square?(to_pos) && board.on_board?(to_pos)
        if !board.is_color?(cap_pos, color) && board.empty_square?(cap_pos)
          arr << to_pos
          arr += Piece.new(color, board, to_pos, kinged).jumping_moves
        end
      end

      if king?
        dx, dy = vector.map{ |v| v * -direction }
        cap_x, cap_y = vector.map{ |v| v * -direction  / 2 }
        to_pos = [x + dx, y + dy]
        cap_pos = [x + cap_x, y + cap_y]
        if board.empty_square?(to_pos) && board.on_board?(to_pos)
          if !board.is_color?(cap_pos, color) && board.empty_square?(cap_pos)
            arr << to_pos
            arr += Piece.new(color, board, to_pos, kinged).jumping_moves
          end
        end
      end
    end
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
