require 'io/console'
require_relative "board"
require_relative "player"
require_relative "errors"

class Checkers

  def initialize(player1, player2)
    @board = Board.new(seed = true)
    @players = [player1, player2]
    establish_connection
    @winner = nil
  end

  def play
    print_instructions
    board.render
    until winner
      play_turn(players.first)
      players.rotate!
      puts "It's now #{players.first.color}'s turn"
    end
    congratulate_winner
  end

  def play_turn(player)
    begin
      player.get_input
      from_pos = board.cursor
      player.get_input
      to_pos   = board.cursor
      check_input(from_pos, to_pos)
      board.move_piece(from_pos, to_pos)
    rescue InvalidSelectionError
      puts "I can't let you do that."
      retry
    end
  end

  def establish_connection
    players[0].receive_game_info(self, :black)
    players[1].receive_game_info(self, :red)
  end

  def move_cursor(input)
    board.update_cursor(input)
  end

  def check_input(from_pos, to_pos)
    # debugger
    player = players.first
    error = false                               # Fix later
    error = true if  board[*from_pos].color != player.color
    error = true if  board[*to_pos].color   == player.color
    error = true if !board[*from_pos].moves.include?(to_pos)
    raise InvalidSelectionError if error
  end

  def print_instructions
    string =  "Welcome to the checkers game, you can move your cursor with\n"
    string += "WASD, and select the piece that you would like to move with\n"
    string += "enter. Press any key when you are ready!"
    puts string
    $stdin.getch
  end

  def congratulate_winner
    puts "Congratulations #{winner.name}! You win."
  end

  private
  attr_reader :winner, :players, :board

end

if __FILE__ == $PROGRAM_NAME
  c = Checkers.new(Player.new, Player.new)
  c.play
end
