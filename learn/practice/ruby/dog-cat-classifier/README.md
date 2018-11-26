# Dog-Cat Classifier

[![](https://circleci.com/gh/croaky/dog-cat-classifier.png?circle-token=cc924c43a7eb42256cec5bfac09b2354ea4bf562)](https://circleci.com/gh/croaky/dog-cat-classifier)

Text your height and weight to `(555) 555-5555`
to have IBM Watson guess whether you're a dog or cat person.

You can use natural language in your text,
such as any of these examples:

```
height 6 foot 5 weight 210
5'4" 120
height 5 foot 2 weight 110
height 6 foot 8 inches 250 pounds
5 foot 8 inches 150 pounds
160cm 70 kilos
150 centimeters 11 stone
180 cm 85 kilos
190cm 13.5 stone
```

## How it works

Dog-Cat Classifier (D-CC) is an SMS-based program
that uses an IBM Watson [Natural Language Classifier][ibm]
to generate artificially intelligent answers to the age-old question
"are you a dog or cat person?"

[ibm]: https://www.ibm.com/watson/developercloud/nl-classifier.html

The classifier is trained on [this data][training]
formatted in [the required CSV format][csv].

[training]: training.csv
[csv]: http://www.ibm.com/watson/developercloud/doc/nl-classifier/data_format.shtml

When a text message is sent to `(555) 555-5555`:

* [Twilio] receives the message and forwards it to the D-CC Sinatra app
  (development environment served via ngrok,
  production environment served via [Heroku]).
* Sinatra passes the text to a `Watson` Plain Old Ruby Object (PORO).
* The `Watson` PORO sends the text to the IBM Watson classifier
  and parses the response for which class name ("dog" or "cat")
  that Watson has higher confidence in.
* Respond to Twilio with text and a cute photo of a dog or cat
  to give the app personality.

[Twilio]: https://www.twilio.com
[Heroku]: https://www.heroku.com

As an example,
Watson might return these confidences when given text `6'5", 210`:

```
0.8424657534246576 dog
0.18824924509647087 cat
```

Since `dog` is the higher confidence, D-CC will answer "dog".
If Watson is unavailable or errors, D-CC will fall back to "dog".

## Train a new Watson classifier

D-CC guesses are saved in a Heroku Postgres database.
At any time,
download [the production data as CSV][dataclip] as the new `training.csv`.

[dataclip]: https://dataclips.heroku.com/flculvewgcvcznvkqeyeddtayusi.csv

Then, run this script to create a new Watson classifier from the latest data:

```
./bin/train
```

Copy the classifier ID from the response.
When it has finished training,
configure it as the new classifier in the production system:

```
heroku config:set CLASSIFIER_ID=#{new_id} --app dog-cat-classifier
```

## Contributing

Set up Ruby dependencies, Postgres database, Heroku access:

```
./bin/setup
```

Run specs:

```
rspec
```
