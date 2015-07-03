require 'io/console'
require 'byebug'

class Player
  attr_accessor :color, :game

  def receive_game_info(game, board, color)
    @game = game
    @color = color
    @board = board
  end

  private
  attr_reader :board
end

class HumanPlayer < Player

  def get_input
    input = $stdin.getch
    loop do
      break if input == "\r"
      exit if input == "p"
      game.move_cursor(input)
      input = $stdin.getch
    end
    input
  end

  def choose_next_jump(jumper_pos)
    begin
      get_input
      raise InvalidSelectionError unless game.is_continuation?(jumper_pos)
    rescue InvalidSelectionError
      puts "You must continue your jump!"
      retry
    end
  end

  def play_turn
    get_input
    from_pos = game.current_selection
    get_input
    to_pos   = game.current_selection
    [from_pos, to_pos]
  end
end

class ComputerPlayer < Player

  def play_turn
    sleep(1)
    jumping_move || random_move
  end

  def jumping_move
    jh = jump_hash
    return nil if jh.empty?

    from_pos = jh.keys.sample
    to_pos   = jh[from_pos].sample

    game.specify_cursor_position(to_pos)
    [from_pos, to_pos]
  end

  def jump_hash
    board.get_pieces(color).each_with_object({}) do |piece, hash|
      j_moves = piece.jumping_moves
      hash[piece.pos] = j_moves if j_moves.length > 0
    end
  end

  def random_move
    rm = board.get_pieces(color).each_with_object({}) do |piece, hash|
      r_moves = piece.moves
      hash[piece.pos] = r_moves if r_moves.length > 0
    end
    from_pos = rm.keys.sample
    to_pos = rm[from_pos].sample
    [from_pos, to_pos]
  end

  def choose_next_jump(jumper_pos)
    sleep(1)
    board[*jumper_pos].moves.sample
  end

end
