# frozen_string_literal: true

require_relative '../../app/models/guess'

ActiveRecord::Base.logger = nil

RSpec.describe Guess, '.create' do
  it "SHA1 hashes user's phone number for some lightweight privacy" do
    guess = Guess.create(input: 'anything', phone_number: '+15555555555')

    expect(guess.user_id).not_to be_nil
  end

  after do
    Guess.destroy_all
  end
end

RSpec.describe Guess, '.by_phone_number' do
  it 'finds guesses for user, sorted by most recent' do
    phone_number = '+15555555555'
    one = Guess.create(input: 'one', phone_number: phone_number)
    two = Guess.create(input: 'two', phone_number: phone_number)
    Guess.create(input: 'not-found', phone_number: '+14151234567')

    guesses = Guess.by_phone_number(phone_number)

    expect(guesses).to eq [two, one]
  end

  after do
    Guess.destroy_all
  end
end

RSpec.describe Guess, '#opposite_animal' do
  it 'returns cat when dog' do
    guess = create_guess(animal: 'dog')

    expect(guess.opposite_animal).to eq 'cat'
  end

  it 'returns dog when cat' do
    guess = create_guess(animal: 'cat')

    expect(guess.opposite_animal).to eq 'dog'
  end

  after do
    Guess.destroy_all
  end
end

def create_guess(animal:)
  Guess.create(
    input: 'anything',
    phone_number: 'anything',
    animal: animal,
  )
end
