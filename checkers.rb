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
      puts "It's now #{players.first.color}'s turn"
      jumped = play_turn(players.first)
      while jump_again? && jumped
        from_pos = board.cursor
        players.first.choose_next_jump(from_pos)
        board.move_piece(from_pos, board.cursor)
      end
      @winner = players.first unless board.has_pieces?(players[1].color)
      players.rotate!
    end
    congratulate_winner
  end

  def play_turn(player)
    begin
      puts "#{player.color.to_s.capitalize}'s turn'"
      from_pos, to_pos = player.play_turn
      check_input(from_pos, to_pos)
      board.move_piece(from_pos, to_pos)
    rescue InvalidSelectionError
      puts "I can't let you do that."
      retry
    rescue MustJumpError
      puts "You must jump!"
      retry
    end
  end

  def establish_connection
    players[0].receive_game_info(self, :black)
    players[1].receive_game_info(self, :red)
  end

  def move_cursor(input)
    board.update_cursor(input, players.first.color)
  end

  def current_selection
    board.cursor
  end

  def check_input(from_pos, to_pos)
    player = players.first
    raise InvalidSelectionError if (board[*from_pos].color != player.color ||
      board[*to_pos].color == player.color ||
      !board[*from_pos].moves.include?(to_pos))
    raise MustJumpError if (board.distance(from_pos, to_pos) < 2 &&
      can_jump?(players.first.color))
  end

  def jumping_pieces(color)
    board.get_pieces(color).select do |piece|
      piece.jumping_moves.length > 0
    end
  end

  def can_jump?(color)
    board.get_pieces(color).any? do |piece|
      piece.jumping_moves.length > 0
    end
  end

  def is_continuation?(jumper_pos)
    board[*jumper_pos].jumping_moves.include?(board.cursor)
  end

  def print_instructions
    string =  "Welcome to the checkers game, you can move your cursor with\n"
    string += "WASD, and select the piece that you would like to move with\n"
    string += "enter. Press any key when you are ready!"
    puts string
    $stdin.getch
  end

  def congratulate_winner
    puts "Congratulations #{winner.color}! You win."
  end

  private
  attr_reader :winner, :players, :board

  def jump_again?
    board[*board.cursor].jumping_moves.length >= 1
  end
end

if __FILE__ == $PROGRAM_NAME
  c = Checkers.new(HumanPlayer.new, HumanPlayer.new)
  c.play
end
