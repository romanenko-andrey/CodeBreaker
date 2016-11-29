require_relative 'rav_codebreaker/version'
require_relative 'rav_codebreaker/game'

module RavCodebreaker
  def self.play(level)
    begin
      game = Game.new(level)
      game.play
    end until game.again?
    #save results to file and show statistic
  end
end

