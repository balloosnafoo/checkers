
class EmptySquare

  def empty?
    true
  end

  def to_s
    "   "
  end

  def inspect
    "empty"
  end

  def color
    nil
  end

  def moves
    []
  end

  def dup(dup_board)
    EmptySquare.new
  end

end
