require 'spec_helper'

module RavCodebreaker
  RSpec.describe Console do
    subject(:game) { Console.new }

    describe '#again?' do
      before do
        allow(game).to receive(:puts)
      end

      it 'return false if a player enter N' do
        allow(game).to receive(:gets).and_return('N')
        expect(game.again?).to be_falsey
      end
      it 'return true if a player enter Y' do
        allow(game).to receive(:gets).and_return('Y')
        expect(game.again?).to be_truthy
      end
      it 'return false if a player enter empty string' do
        allow(game).to receive(:gets).and_return('')
        expect(game.again?).to be_falsey
      end
    end

    describe '#play with Beginner level' do
      subject(:beginner_game){ Console.new(:beginner) }

      before do
        allow(beginner_game).to receive(:save_results)
        allow(beginner_game).to receive(:show_results)
      end

      it 'finish the game after enter a correct answer' do
        allow(beginner_game).to receive(:gets).and_return('1234')
        allow_any_instance_of(Game).to receive(:win?).and_return(true)
        expect{beginner_game.play}.to output(/We congratulate you on your victory/).to_stdout
      end

      it 'finish the game after 20 failure attempts' do
        allow(beginner_game).to receive(:gets).exactly(20).times.and_return('2222')
        expect{beginner_game.play}.to output(/Sorry, you lose the game/).to_stdout
      end

      it 'gives 2 hints for help' do
        allow(beginner_game).to receive(:gets).exactly(23).times.and_return('H', 'h', 'h', '2222')

        expect{beginner_game.play}.to output( a_string_matching("You have 20 attempts and 2 hints")
                                         .and a_string_matching("You have 20 attempts and 1 hints")
                                         .and a_string_matching("You have 20 attempts and 0 hints")
                                         .and a_string_matching("Sorry, but you have not any hints") ).to_stdout

      end
    end

    describe '#play with Master level' do
      subject(:master_game){ Console.new(:master) }

      before do
        allow(master_game).to receive(:save_results)
        allow(master_game).to receive(:show_results)
      end

      it 'finish the game after enter a correct answer' do
        allow(master_game).to receive(:gets).and_return('1234')
        allow_any_instance_of(Game).to receive(:win?).and_return(true)
        expect{master_game.play}.to output(/We congratulate you on your victory/).to_stdout
      end

      it 'finish the game after 15 failure attempts' do
        allow(master_game).to receive(:gets).exactly(15).times.and_return('2222')
        expect{master_game.play}.to output(/Sorry, you lose the game/).to_stdout
      end

      it 'gives 1 hints for help' do
        allow(master_game).to receive(:gets).exactly(17).times.and_return('H', 'h', '2222')

        expect{master_game.play}.to output(a_string_matching("You have 15 attempts and 1 hints")
                                      .and a_string_matching("You have 15 attempts and 0 hints")
                                      .and a_string_matching("Sorry, but you have not any hints") ).to_stdout
      end
    end

    describe '#play with Expert level' do
      subject(:expert_game){ Console.new(:expert) }

      before do
        allow(expert_game).to receive(:save_results)
        allow(expert_game).to receive(:show_results)
      end

      it 'finish the game after enter a correct answer' do
        allow(expert_game).to receive(:gets).and_return('1234')
        allow_any_instance_of(Game).to receive(:win?).and_return(true)
        expect{expert_game.play}.to output(/We congratulate you on your victory/).to_stdout
      end

      it 'finish the game after 10 failure attempts' do
        allow(expert_game).to receive(:gets).exactly(10).times.and_return('2222')
        expect{expert_game.play}.to output(/Sorry, you lose the game/).to_stdout
      end

      it 'gives 0 hints for help' do
        allow(expert_game).to receive(:gets).exactly(11).times.and_return('h', '2222')
        expect{expert_game.play}.to output(/Sorry, but you have not any hints/).to_stdout
      end
    end
  end
end