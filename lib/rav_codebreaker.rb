require_relative 'rav_codebreaker/version'
require_relative 'rav_codebreaker/game'
require_relative 'rav_codebreaker/console'
module RavCodebreaker
  def self.play(level)
    begin
      console = Console.new(level)
      console.play
    end while console.again?
  end
end

