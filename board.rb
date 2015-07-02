require 'colorize'
require 'io/console'
require 'byebug'
require_relative "piece"
require_relative "empty_square"

class Board
  attr_reader :cursor

  def initialize(seed = false)
    @grid = blank_grid
    @cursor = [0, 0]
    seed_board if seed
    @active_moveset = []
  end

  def blank_grid
    Array.new(8){ Array.new(8) { EmptySquare.new } }
  end

  SEED_RANGES = {
    :red => (5..7),
    :black => (0..2)
  }

  def seed_board
    seed_color(:red)
    seed_color(:black)
  end

  def seed_color(color)
    SEED_RANGES[color].each do |i|
      piece_switch = i % 2
      (0..7).each do |j|
        if (piece_switch + j) % 2 == 0
          self[i, j] = Piece.new(color, self, [i,j])
        end
      end
    end
  end

  BACKGROUND_COLORS = [:white, :light_black]

  def render
    system("clear")
    grid.each_with_index do |row, i|
      bg_idx = i % 2
      row.each_with_index do |cell, j|
        if [i, j] == cursor
          print cell.to_s.colorize(background: :green)
        elsif @active_moveset.include?([i, j])
          print cell.to_s.colorize(background: :yellow)
        else
          bg_color = BACKGROUND_COLORS[(bg_idx + j) % 2]
          print cell.to_s.colorize(background: bg_color)
        end
      end
      puts
    end
  end

  def empty_square?(pos)
    row, col = pos
    self[row, col].empty?
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def is_color?(pos, color)
    self[*pos].color == color
  end

  def move_piece(from_pos, to_pos)
    self[*to_pos] = self[*from_pos]
    self[*to_pos].update_position(to_pos)
    self[*from_pos] = EmptySquare.new
    if distance?(from_pos, to_pos) > 1
      captured_piece(from_pos, to_pos)
    end
    maybe_promote(to_pos)
    render
  end

  def maybe_promote(pos)
    self[*pos].promote if pos[0] == 0 || pos[0] == 7
  end

  def distance?(from_pos, to_pos)
    (from_pos[0] - to_pos[0]).abs
  end

  def captured_piece(from_pos, to_pos)
    cap_x = (from_pos[0] + to_pos[0]) / 2
    cap_y = (from_pos[1] + to_pos[1]) / 2
    self[cap_x, cap_y] = EmptySquare.new
  end

  MOVEMENTS = {
    "w"  => [-1, 0],
    "a"  => [0, -1],
    "s"  => [ 1, 0],
    "d"  => [ 0, 1],
    "\r" => [ 0, 0]
  }

  def update_cursor(input)
    c_row, c_col = cursor
    d_row, d_col = MOVEMENTS[input]
    new_pos = [c_row + d_row, c_col + d_col]
    @cursor = new_pos if on_board?(new_pos)
    @active_moveset = self[*cursor].moves
    render
  end

  def [](row, col)
    grid[row][col]
  end

  def []=(row, col, val)
    @grid[row][col] = val
  end

  private
  attr_reader :grid

end

if __FILE__ == $PROGRAM_NAME
  b = Board.new(true)
  b.get_input
end
