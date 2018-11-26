# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'sinatra'

Dotenv.load

require_relative 'app/models/guess'
require_relative 'app/models/watson'

post '/message' do
  content_type 'text/xml'
  handle_input input: params['Body'], phone_number: params['From']
end

get '/:image' do
  send_file "images/#{params[:image]}", disposition: 'inline'
end

def handle_input(input:, phone_number:)
  if input == 'yes'
    <<-TWIML
      <Response>
        <Message>
          I thought so!
        </Message>
      </Response>
    TWIML
  elsif input == 'no'
    guess = Guess.by_phone_number(phone_number).first

    if guess
      guess.update(correct: false)
      animal = guess.opposite_animal
      <<-TWIML
        <Response>
          <Message>
            <Body>
              My deepest apologies. :(
            </Body>
            <Media>
              #{ENV.fetch('APP_URL', 'http://localhost:4567')}/#{animal}.jpg
            </Media>
          </Message>
        </Response>
      TWIML
    end
  else
    answer = classify(input)
    Guess.create(input: input, phone_number: phone_number, animal: answer)
    <<-TWIML
      <Response>
        <Message>
          <Body>
            You're a #{answer} person! Am I right? (yes/no)
          </Body>
          <Media>
            #{ENV.fetch('APP_URL', 'http://localhost:4567')}/#{answer}.jpg
          </Media>
        </Message>
      </Response>
    TWIML
  end
end

def classify(input)
  watson = Watson.new(
    id: ENV.fetch('CLASSIFIER_ID', 'test'),
    password: ENV.fetch('WATSON_PASSWORD', 'test'),
    username: ENV.fetch('WATSON_USERNAME', 'test'),
  )
  watson.classify(input)
end
