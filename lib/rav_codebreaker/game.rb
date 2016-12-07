module RavCodebreaker
  class Game
    TURNS_COUNT = {expert: 10, master: 15, beginner: 20}
    HINTS_COUNT = {expert: 0, master: 1, beginner: 2}

    attr_reader  :turns_left, :hints_left, :secret_code, :level
    attr_accessor :offer

    def initialize(level = :expert)
      @secret_code = ''
      @turns_left = 0
      TURNS_COUNT.keys.include?(level) ? @level = level : @level = :expert
    end

    def start
      @secret_code = Array.new(4){rand(1..6)}*''
      @turns_left = TURNS_COUNT[@level]
      @hints_left = HINTS_COUNT[@level]
      @offer = '6666'
    end

    def decode_offer
      code = @secret_code.split('')
      offer = @offer.split('')
      4.times{|i| code[i] = offer[i] = nil if @secret_code[i] == @offer[i]}
      offer.compact!
      offer.each{|num| code[code.index(num)] = '-' if code.include? num}
      '+' * code.count(nil) + '-' * code.count('-')
    end

    def get_hint
      return nil if @hints_left < 1
      @hints_left -= 1
      pos = rand(4)
      [@secret_code[pos], pos]  
    end

    def next_turn
      @turns_left -= 1
    end

    def win?
      decode_offer == '++++'
    end

    def format_error?
      @offer !~ /^[1-6]{4}$/ && @offer !~ /^[hH]$/
    end

    def exit?
      @offer =~ /^[qQ]$/
    end

    def game_over?
      @turns_left < 1
    end

    def show_hint?
      @offer =~ /^[hH]$/
    end
  end
end