require 'spec_helper'

module RavCodebreaker
  RSpec.describe Game do
    context '#Start' do
      let(:game) { Game.new }
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

    end

    describe '#Guess' do
      subject(:game) { Game.new }
      before { game.start }

      context '#Guess_proposition' do
        it 'invite to quess the secret code' do
          #expect(game.submit_to_guess).not_to be_empty
        end
      end
    end
  end
end