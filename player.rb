require 'io/console'
require 'byebug'

class Player
  attr_accessor :color, :game

  def receive_game_info(game, board, color)
    @game = game
    @color = color
    @board = board
  end

  def other_color
    color == :red ? :black : :red
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
      raise MustJumpError unless game.is_continuation?(jumper_pos)
    rescue MustJumpError
      puts "You must continue your jump!"
      retry
    end
  end

  def play_turn
    get_input
    from_pos = game.current_selection
    raise InvalidSelectionError if board[*from_pos].color != color
    get_input
    to_pos   = game.current_selection
    [from_pos, to_pos]
  end
end

class ComputerPlayer < Player

  def play_turn
    sleep(1)
    jumping_move || least_cost_move
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

  def least_cost_move
    pieces = board.get_pieces(color)
    lcm_jump,  jump_cost  = least_cost_moves(pieces, :jumping_moves)
    lcm_slide, slide_cost = least_cost_moves(pieces, :sliding_moves)
    case jump_cost <=> slide_cost
    when 1
      move = lcm_slide.sample
    when 0
      move = (lcm_slide + lcm_jump).sample
    when -1
      move = lcm_jump.sample
    end
    puts "I'm executing this move:"
    p move
    move
  end

  def least_cost_moves(pieces, move_type)
    # debugger
    lowest_cost = 99
    lowest_cost_moves = []
    offset = move_type == :jumping_moves ? 1 : 0

    pieces.each do |piece|
      piece.send(move_type).each do |jump|
        cost = expected_loss(piece.pos, jump) - offset
        if cost < lowest_cost
          lowest_cost = cost
          lowest_cost_moves = [[piece.pos, jump]]
        elsif cost == lowest_cost
          lowest_cost_moves << [piece.pos, jump]
        end
      end
    end
    puts "I found the following #{move_type} at cost #{lowest_cost}"
    p lowest_cost_moves
    [lowest_cost_moves, lowest_cost]
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
    game.specify_cursor_position(board[*jumper_pos].jumping_moves.sample)
  end

  def expected_loss(from_pos, to_pos)
    dup_board = board.deep_dup
    dup_board.move_piece!(from_pos, to_pos, false)

    moving_piece = dup_board[*to_pos]
    moving_color = moving_piece.color
    opp_color    = moving_piece.other_color
    opp_pieces   = dup_board.get_pieces(moving_piece.other_color)

    return 0 if opp_pieces.all? { |piece| piece.jumping_moves.empty? }
    longest = 0
    opp_pieces.each do |piece|
      best_move_length = longest_jump(piece.pos, dup_board, opp_color)
      longest = best_move_length if best_move_length > longest
    end
    puts "I found an expected loss of #{longest}"
    longest
  end

  def longest_jump(pos, board, color)
    return 0 if board[*pos].jumping_moves.empty?
    
    board[*pos].jumping_moves.each do |move|
      dup_board = board.deep_dup
      dup_board.move_piece!(pos, move, false)
      return 1 + longest_jump(move, dup_board, color)
    end
  end


end
