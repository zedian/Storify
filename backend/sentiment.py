from __future__ import absolute_import, division, print_function, unicode_literals
from flask import Flask, request
import json
import requests
import base64
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

sentiment = Flask(__name__)

def run_sentiment_analysis(text):
    URL = "https://api.spotify.com/"
    auth = "https://accounts.spotify.com/api/token"
    client_id = "13186e9c43c54bd9b02876922e205da6"
    client_secret = "ad49eaa89c234431bb3a0b677d6b862c"
    response_type = "token"
    redirect_url = "https://localhost"
    key = 'f0064908730c453cbed016cfa70e8c01'
    endpoint = 'westus.api.cognitive.microsoft.com'
    appId = '6646e66e-73b9-4fa3-a0cd-1a063818e3e7'
    utterance = text
    headers = {}
    params = {
        'query': utterance,
        'timezoneOffset': '0',
        'verbose': 'true',
        'show-all-intents': 'true',
        'spellCheck': 'false',
        'staging': 'false',
        'subscription-key': key
    }
    r = requests.get(f'https://{endpoint}/luis/prediction/v3.0/apps/{appId}/slots/production/predict',headers=headers, params=params)
    response_data = r.json()
    intent = response_data['prediction']['topIntent']
    if intent == 'None':
        return 'spotify:album:6N9PS4QXF1D0OWPk0Sxtb4'
    client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    result = sp.recommendations(seed_genres={intent}) #search query
    return result['tracks'][0]['album']['uri']

@sentiment.route('/', methods=['POST'])
def geturi():
    print("enter")
    text = request.form.get('text')
    generated = {"uri": run_sentiment_analysis(text)}
    return json.dumps(generated)


if __name__ == "__main__":
    sentiment.run(host='localhost', port=9021, debug = True)
