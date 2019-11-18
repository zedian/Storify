# Musical Journal APIs

> This repository stores two APIs called by the Musical Journal Application

## Spotify Music Query API

This one is under `sentiment.py`. It takes as input a data object with key `text` and returns an `uri` with the spotify album. 
It also makes a call to the LUIS api, on which we created multiple class and essentially classifies the genre with highest probably from the intent. This doesn't really make much sense, but it was a quick hack we made.

## Text Generation

This one is under `app.py`. It takes as input a data object with key `text` and returns a json object with three fields, three different generated text from the decoding algorithm specified in the CTRL paper. (top k decoding algorithm with `k=1`)

