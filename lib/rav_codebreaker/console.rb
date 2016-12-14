require 'colorize'
module RavCodebreaker
  class Console
    SCORES_FILE_NAME = './score.dat'

    def initialize(level = :expert)
      @score = []
      @game = Game.new(level)
    end

    def play
      welcome_message
      @game.start   
      begin
        get_offer
        case 
          when @game.exit?
            exit
          when @game.show_hint?
            show_hint
            next
          when @game.format_error?
            show_incorrect_message
            next
          when @game.win?
            show_winner_message
          else
            show_result_message
            @game.next_turn 
            show_gameover_message if @game.game_over?
        end
      end until @game.win? || @game.game_over?
      save_and_show_results
    end

    def get_offer
      show_invitation_message      
      @game.offer = gets.chomp
    end

    def again?
      puts 'Do you want to play again (Y or N)'.bold
      gets =~ /y|Y/
    end

    def welcome_message
      puts '='*80
      puts 'Welcome to play the CodeBreaker Game!!!'.green
      puts '='*80
    end

    def show_invitation_message
      puts "Try to guess the secret code!\n"+
      "You have #{@game.turns_left} attempts and #{@game.hints_left} hints. Good luck!\n" +
      "Enter you four numbers code (from 1 to 6), please (or Q - for exit, H - for hint):"
    end

    def show_incorrect_message
      puts "\nincorrect number format, try again, please..."
    end

    def show_result_message
      puts "You result is \"#{@game.decode_offer}\"!".green
    end

    def show_gameover_message
      puts "Sorry, you lose the game :(\nThe secret code was #{@game.secret_code}.".red
    end

    def show_winner_message
      puts 'We congratulate you on your victory!!!'.green
    end

    def show_hint
      hint = @game.get_hint
      if hint
        puts "I exactly know that a number #{hint.first} is at position ##{hint.last} (remember, it starts from 0).\n".green
      else
        puts 'Sorry, but you have not any hints :('.red
      end
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
      format_str = "| %02s | %12s | %10s | %5s | %5s |"
      format_str_length = 50
      puts '-' * format_str_length
      puts format_str % %w(## player\ name game\ level turns hints)
      puts '-' * format_str_length
      @score.each_with_index do |player, index|
        arr = [index + 1] + player.values
        puts format_str % arr
      end
      puts '-' * format_str_length
    end

    def save_results
      puts '"Do you want to save your results (Y/N)?'
      return if gets !~ /y|Y/
      player = {}
      begin
        puts 'Enter your name, please...'
        player[:name] = gets.chomp
      end while player[:name].empty?
      player[:level] = @game.level
      player[:turns] = Game::TURNS_COUNT[@game.level] - @game.turns_left
      player[:hints] = Game::HINTS_COUNT[@game.level] - @game.hints_left
      @score << player
      save_scores_to_file
    end

    def save_and_show_results
      load_scores_from_file
      save_results
      show_results
    end

  end
end
