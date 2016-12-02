require 'spec_helper'

module RavCodebreaker
  RSpec.describe Game do
    let(:game) { Game.new }

    describe '#Start' do
      let(:game_secret_code) { game.instance_variable_get(:@secret_code) }
      before do
        game.start
      end

      it 'generates secret code' do
        expect(game_secret_code).not_to be_empty
      end

      it 'saves 4 numbers secret code' do
        expect(game_secret_code.size).to eq(4)
      end

      it 'saves secret code with numbers from 1 to 6' do
        expect(game_secret_code).to match(/[1-6]{4}/)
      end

      it 'generates uniq secret code for different games' do
        another_game = Game.new.start
        code_for_another_game = another_game.instance_variable_get(:@secret_code)
        expect(game_secret_code).not_to eq(code_for_another_game)
      end


      context 'with Error level' do
        error_game = Game.new(:error_level)
        error_game.start
        it 'starts with Master Level settings' do
          expect(error_game.turns_left).to eq(10)
          expect(error_game.hints_left).to eq(0)
        end
      end

      context 'with Beginner level' do
        beginner_game = Game.new(:beginner)
        beginner_game.start
        it 'gives up to 20 attempts to guess the secret code' do
          expect(beginner_game.turns_left).to eq(20)
        end
        it 'gives up to 2 hints to guess the secret code' do
          expect(beginner_game.hints_left).to eq(2)
        end
      end

      context 'with Master level' do
        master_game = Game.new(:master)
        master_game.start
        it 'gives up to 20 attempts to guess the secret code' do
          expect(master_game.turns_left).to eq(15)
        end
        it 'gives up to 2 hints to guess the secret code' do
          expect(master_game.hints_left).to eq(1)
        end
      end

      context 'with Expert level' do
        expert_game = Game.new(:expert)
        expert_game.start
        it 'gives up to 10 attempts to guess the secret code' do
          expect(expert_game.turns_left).to eq(10)
        end
        it 'no gives hints to guess the secret code' do
          expect(expert_game.hints_left).to eq(0)
        end
      end
    end

    describe '#decode_offer' do
      tests = [{secret: '1234', offer: '3333', decode: '+'},
               {secret: '1111', offer: '3333', decode: ''},
               {secret: '1234', offer: '2122', decode: '--'},
               {secret: '1234', offer: '4216', decode: '+--'},
               {secret: '1234', offer: '4321', decode: '----'},
               {secret: '1122', offer: '1221', decode: '++--'},
               {secret: '1313', offer: '3412', decode: '+-'}]
      let (:game) { Game.new }
      tests.each do |test|
        it "for secret code #{test[:secret]} and offer #{test[:offer]} must be \"#{test[:decode]}\"" do
          game.instance_variable_set(:@secret_code, test[:secret])
          game.instance_variable_set(:@offer, test[:offer])
          expect(game.decode_offer).to eq(test[:decode])
        end
      end
    end

    describe '#again?' do
      it 'return false if a gamer enter N' do
        allow(game).to receive(:gets).and_return('N')
        expect(game.again?).to be_falsey
      end
      it 'return true if a gamer enter Y' do
        allow(game).to receive(:gets).and_return('Y')
        expect(game.again?).to be_truthy
      end
      it 'return false if a gamer enter empty string' do
        allow(game).to receive(:gets).and_return('')
        expect(game.again?).to be_falsey
      end
    end

    describe '#test_offer' do
      before do
        game.start
        game.instance_variable_set(:@secret_code, '1111')
        game.instance_variable_set(:@offer, '2112')
      end
      it 'decrease @turns_left variable after each test' do
        expect{game.test_offer}.to change{ game.turns_left }.by(-1)
      end
      it "decode gamer\'s inputs and prints decoding result to console" do
        expect{game.test_offer}.to output("You result is \"++\"!\n").to_stdout
      end
    end

    describe '#format_error?' do
      it 'return false if code-breakers answer has correct format' do
       game.instance_variable_set(:@offer, '1234')
       expect(game.format_error?).to be_falsy
      end
      it 'return true if code-breakers answer has less then 4 numbers' do
       game.instance_variable_set(:@offer, '123')
       expect(game.format_error?).to be_truthy
      end
      it 'return true if code-breakers answer has more then 4 numbers' do
       game.instance_variable_set(:@offer, '12345')
       expect(game.format_error?).to be_truthy
      end
      it 'return true if code-breakers answer contains incorrect numbers' do
        game.instance_variable_set(:@offer, '0123')
        expect(game.format_error?).to be_truthy
      end
      it "return false if code-breakers answer equal 'H' or 'h'" do
        game.instance_variable_set(:@offer, 'h')
        expect(game.format_error?).to be_falsy
        game.instance_variable_set(:@offer, 'H')
        expect(game.format_error?).to be_falsy
      end
    end

    describe '#play with Beginner level' do
      let(:beginner_game){ Game.new(:beginner) }

      before do
        beginner_game.start
        beginner_game.instance_variable_set(:@secret_code, '1234')
        allow(beginner_game).to receive(:start)
        allow(beginner_game).to receive(:save_results)
        allow(beginner_game).to receive(:show_results)
      end

      it 'finish the game after enter the correct answer' do
        allow(beginner_game).to receive(:gets).and_return('1234')
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
      let(:master_game){ Game.new(:master) }

      before do
        master_game.start
        master_game.instance_variable_set(:@secret_code, '1234')
        allow(master_game).to receive(:start)
        allow(master_game).to receive(:save_results)
        allow(master_game).to receive(:show_results)
      end

      it 'finish the game after enter the correct answer' do
        allow(master_game).to receive(:gets).and_return('1234')
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
      let(:expert_game){ Game.new(:expert) }

      before do
        expert_game.start
        expert_game.instance_variable_set(:@secret_code, '1234')
        allow(expert_game).to receive(:start)
        allow(expert_game).to receive(:save_results)
        allow(expert_game).to receive(:show_results)
      end

      it 'finish the game after enter the correct answer' do
        allow(expert_game).to receive(:gets).and_return('1234')
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