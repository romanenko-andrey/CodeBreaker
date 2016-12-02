require_relative 'rav_codebreaker/version'
require_relative 'rav_codebreaker/game'

module RavCodebreaker
  def self.play(level)
    begin
      game = Game.new(level)
      game.play
    end while game.again?
  end
end

