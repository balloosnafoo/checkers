require 'io/console'
require 'byebug'

class Player
  attr_accessor :color, :game

  def receive_game_info(game, color)
    @game = game
    @color = color
  end

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

end
