require_relative 'rav_codebreaker/version'
require_relative 'rav_codebreaker/game'
require_relative 'rav_codebreaker/console'

module RavCodebreaker
  def self._play(level)
    begin
      game = Game.new(level)
      game.play
    end while game.again?
  end

  def self.play(level)
    begin
      console = Console.new(level)
      console.play
    end while console.again?
  end

end

