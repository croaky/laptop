# frozen_string_literal: true

class AddAnimalToGuesses < ActiveRecord::Migration[5.1]
  def change
    add_column :guesses, :animal, :string, default: 'dog', null: false
  end
end
