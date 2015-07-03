require 'byebug'

class Piece
  JUMPING_VECTORS = [[2, 2], [2, -2]]
  SLIDING_VECTORS = [[1, 1], [1, -1]]

  attr_accessor :pos
  attr_reader :color

  def initialize(color, board, pos, kinged = false)
    @color  = color
    @board  = board
    @pos    = pos
    @kinged = kinged
    @direction = color == :black ? 1 : -1
  end

  def moves
    jumping_moves + sliding_moves
  end

  def jumping_moves
    JUMPING_VECTORS.each_with_object([]) do |vector, arr|
      jump_for_vector(vector,  direction, arr)
      if kinged
        jump_for_vector(vector, -direction, arr)
      end
    end
  end

  def sliding_moves
    SLIDING_VECTORS.each_with_object([]) do |vector, arr|
      slide_for_vector(vector,  direction, arr)
      slide_for_vector(vector, -direction, arr) if kinged
    end
  end

  def update_position(new_position)
    @pos = new_position
  end

  def promote
    @kinged = true
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

  def jump_for_vector(vector, dir_switch, arr)
    x, y = pos
    dx, dy = vector.map{ |v| v * dir_switch }
    cap_x, cap_y = vector.map{ |v| v * dir_switch / 2 }
    to_pos = [x + dx, y + dy]
    cap_pos = [x + cap_x, y + cap_y]
    if (board.on_board?(to_pos) && board.empty_square?(to_pos)) &&
      (!board.is_color?(cap_pos, color) && !board.empty_square?(cap_pos))
        arr << to_pos
    end
  end

  def slide_for_vector(vector, dir_switch, arr)
    x, y = pos
    dx, dy = vector.map{ |v| v * dir_switch }
    to_pos = [x + dx, y + dy]
    arr << to_pos if board.on_board?(to_pos) && board.empty_square?(to_pos)
  end
end
