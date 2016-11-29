module RavCodebreaker
  class Game
    TURNS_COUNT = {expert: 10, master: 15, beginner: 20}
    HINTS_COUNT = {expert: 0, master: 1, beginner: 2}
    SCORES_FILE_NAME = './score.dat'

    attr_reader  :turns_left, :hints_left, :offer

    def initialize(level = :expert)
      @secret_code = ''
      @turns_left = 0
      @level = level
      @score = []
    end

    def start
      @secret_code = Array.new(4){rand(1..6)}*''
      @turns_left = TURNS_COUNT[@level]
      @hints_left = HINTS_COUNT[@level]
      @offer = '6666'
    end

    def play
      start
      welcome_message
      loop do
        puts format_error? ? incorrect_message : invitation_message
        get_offer
        exit if exit?
        next if show_hint? || format_error?
        test_offer
        show_winner_message if win?
        show_game_over_message if game_over?
        break if win? || game_over?
      end
      load_scores_from_file
      save_results
      show_results
    end

    private

    def welcome_message
      puts '='*80
      puts 'Welcome to play the CodeBreaker Game!!!'
      puts '='*80
    end

    def invitation_message
      "Try to guess the secret code! You have #{@turns_left} attempts and #{@hints_left} hints. Good luck!" +
      "\nEnter you four numbers code (from 1 to 6), please (or Q - for exit, H - for hint):"
    end

    def incorrect_message
      "\nincorrect number format, try again, please..."
    end

    def decode_offer
      code = @secret_code.split('')
      offer = @offer.split('')
      4.times{|i| code[i] = offer[i] = nil if @secret_code[i] == @offer[i]}
      offer.compact!
      offer.each{|num| code[code.index(num)] = '-' if code.include? num}
      '+' * code.count(nil) + '-' * code.count('-')
    end

    def get_offer
      @offer = gets.chomp
    end

    def test_offer
      @turns_left -= 1
      puts "You result is \"#{decode_offer}\"!"
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

    def show_game_over_message
      puts 'Sorry, you lose the game :('
      puts "The secret code was #{@secret_code}."
    end

    def show_winner_message
      puts 'We congratulate you on your victory!!!'
    end

    def again?
      puts 'Do you want to play again (Y or N)'
      gets =~ /n|N/
    end

    def show_hint?
      return false unless @offer =~ /^[hH]$/
      if @hints_left < 1
        puts 'Sorry, but you have not any hints :('
      else
        @hints_left -= 1
        pos = rand(4)
        puts "I exactly know that a number #{@secret_code[pos]} is at position ##{pos} (remember, it starts from 0)."
      end
      true
    end

    def load_scores_from_file
      return unless File.exist? SCORES_FILE_NAME
      File.open(SCORES_FILE_NAME) do |file|
        @score = Marshal.load(file)
      end
    end

    def save_scores_to_file
      File.open(SCORES_FILE_NAME, 'w+') do |file|
        Marshal.dump(@score, file)
      end
    end

    def show_results
      @score.sort_by!{|player| player[:turns]}
      format_str = "| %02s | %10s | %10s | %5s | %5s |"
      format_str_length = 48
      puts '-' * format_str_length
      puts format_str % ['##', 'gamer name', 'game level', 'turns', 'hints']
      puts '-' * format_str_length
      @score.each_with_index do |player, index|
        arr = [index + 1] + player.values
        puts format_str % arr
      end
      puts '-' * format_str_length
    end

    def save_results
      puts "Do you want to save your results (Y/N)?"
      return if gets !~ /y|Y/
      player = {}
      begin
        puts 'Enter your name, please...'
        player[:name] = gets.chomp
      end while player[:name].empty?
      player[:level] = @level
      player[:turns] = TURNS_COUNT[@level] - @turns_left
      player[:hints] = HINTS_COUNT[@level] - @hints_left
      @score << player
      save_scores_to_file
    end
  end
end