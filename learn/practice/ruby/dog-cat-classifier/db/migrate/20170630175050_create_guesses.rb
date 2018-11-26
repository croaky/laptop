# frozen_string_literal: true

class CreateGuesses < ActiveRecord::Migration[5.1]
  def change
    create_table :guesses do |t|
      t.timestamps null: false
      t.string :user_id, null: false, index: true
      t.string :input, null: false
      t.boolean :correct, default: true, null: false
    end
  end
end
