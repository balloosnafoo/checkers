require 'io/console'

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

end
