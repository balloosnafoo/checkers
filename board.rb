require 'colorize'
require 'io/console'
require 'byebug'
require_relative "piece"
require_relative "empty_square"

class Board

  def initialize
    @grid = blank_grid
    @cursor = [0, 0]
  end

  def blank_grid
    Array.new(8){ Array.new(8) { EmptySquare.new } }
  end

  BACKGROUND_COLORS = [:white, :light_black]

  def render
    system("clear")
    grid.each_with_index do |row, i|
      bg_idx = i % 2
      row.each_with_index do |cell, j|
        # debugger
        if [i, j] == cursor
          print cell.to_s.colorize(background: :green)
        else
          bg_color = BACKGROUND_COLORS[(bg_idx + j) % 2]
          print cell.to_s.colorize(background: bg_color)
        end
      end
      puts
    end
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
    @cursor = [c_row + d_row, c_col + d_col]
    render
  end

  #ONLY FOR TESTING, MOVE TO GAME LATER
  def get_input
    loop do
      input = $stdin.getch
      exit if "p" == input
      update_cursor(input)
    end
  end

  private
  attr_reader :grid
  attr_accessor :cursor

end
