# frozen_string_literal: true

require 'digest'
require 'sinatra/activerecord'

class Guess < ActiveRecord::Base
  before_create :hash_phone_number_to_user_id

  attr_accessor :phone_number

  def self.by_phone_number(phone_number)
    where(user_id: Digest::SHA1.hexdigest(phone_number))
      .order(created_at: :desc)
  end

  def opposite_animal
    if animal == 'cat'
      'dog'
    else
      'cat'
    end
  end

  private

  def hash_phone_number_to_user_id
    self.user_id = Digest::SHA1.hexdigest(phone_number)
  end
end
