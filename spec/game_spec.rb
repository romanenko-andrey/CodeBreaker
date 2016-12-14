require 'spec_helper'

module RavCodebreaker
  RSpec.describe Game do
    subject(:game) { Game.new }

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
        it 'gives only 1 hints to guess the secret code' do
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
               {secret: '1313', offer: '3412', decode: '+-'},
               {secret: '1243', offer: '1234', decode: '++--'},
               {secret: '4444', offer: '4111', decode: '+'},
               {secret: '4611', offer: '1466', decode: '---'},
               {secret: '5451', offer: '4445', decode: '+-'},
               {secret: '5432', offer: '2345', decode: '----'},
               {secret: '5556', offer: '1115', decode: '-'}]
      let (:game) { Game.new }
      tests.each do |test|
        it "for secret code #{test[:secret]} and offer #{test[:offer]} must be \"#{test[:decode]}\"" do
          game.instance_variable_set(:@secret_code, test[:secret])
          game.instance_variable_set(:@offer, test[:offer])
          expect(game.decode_offer).to eq(test[:decode])
        end
      end
    end

    describe '#next_turn' do
      before do
        game.start
        game.instance_variable_set(:@secret_code, '1111')
        game.instance_variable_set(:@offer, '2112')
      end
      it 'decrease @turns_left variable after each test' do
        expect{game.next_turn}.to change{ game.turns_left }.by(-1)
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
  end  
end