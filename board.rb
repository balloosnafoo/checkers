require 'colorize'
require 'io/console'
require 'byebug'
require_relative "piece"
require_relative "empty_square"

class Board
  BACKGROUND_COLORS = [:white, :light_black]

  MOVEMENTS = {
    "w"  => [-1, 0],
    "a"  => [0, -1],
    "s"  => [ 1, 0],
    "d"  => [ 0, 1],
    "\r" => [ 0, 0]
  }

  SEED_RANGES = {
    :red => (5..7),
    :black => (0..2)
  }

  def self.blank_grid
    Array.new(8){ Array.new(8) { EmptySquare.new } }
  end

  attr_accessor :cursor

  def initialize(seed = false)
    @grid = self.class.blank_grid
    @cursor = [0, 0]
    seed_board if seed
    @active_moveset = []
  end

  def seed_board
    seed_color(:red)
    seed_color(:black)
  end

  def seed_color(color)
    SEED_RANGES[color].each do |i|
      piece_switch = i % 2
      (0..7).each do |j|
        self[i, j] = Piece.new(color, self, [i, j]) if (piece_switch + j).even?
      end
    end
  end

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

  def has_pieces?(color)
    get_pieces(color).length > 0
  end

  def empty_square?(pos)
    self[*pos].empty?
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def is_color?(pos, color)
    self[*pos].color == color
  end

  def move_piece(from_pos, to_pos)
    self[*to_pos] = self[*from_pos]
    self[*to_pos].pos = to_pos
    self[*from_pos] = EmptySquare.new
    if distance(from_pos, to_pos) > 1
      capture_piece(from_pos, to_pos)
      jumped = true
    end
    maybe_promote(to_pos)
    render
    jumped ? true : false
  end

  def maybe_promote(pos)
    self[*pos].promote if pos[0] == 0 || pos[0] == 7
  end

  def distance(from_pos, to_pos)
    (from_pos[0] - to_pos[0]).abs
  end

  def capture_piece(from_pos, to_pos)
    cap_x = (from_pos[0] + to_pos[0]) / 2
    cap_y = (from_pos[1] + to_pos[1]) / 2
    self[cap_x, cap_y] = EmptySquare.new
  end

  def update_cursor(input, color)
    c_row, c_col = cursor
    d_row, d_col = MOVEMENTS[input]
    new_pos = [c_row + d_row, c_col + d_col]
    @cursor = new_pos if on_board?(new_pos)
    @active_moveset = valid_moves(color)
    render
  end

  def valid_moves(color)
    return [] if self[*cursor].empty? || self[*cursor].color != color
    if get_pieces(color).any? { |piece| piece.jumping_moves.length > 0 }
      self[*cursor].jumping_moves
    else
      self[*cursor].moves
    end
  end

  def get_pieces(color)
    grid.flatten.select { |piece| piece.color == color }
  end

  def deep_dup
    db = Board.new
    grid.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        db[i, j] = cell.dup 
      end
    end
    db
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
