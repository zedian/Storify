########### Python 3.6 #############
import requests

try:

    key = 'f0064908730c453cbed016cfa70e8c01'
    endpoint = 'westus.api.cognitive.microsoft.com' # such as 'westus2.api.cognitive.microsoft.com' 
    appId = '6646e66e-73b9-4fa3-a0cd-1a063818e3e7'
    utterance = 'I am feeling ill, life sucks. I have no friends, but I am trying to meet new people. Yesterday, I ate lunch by myself.'

    headers = {
    }

    params ={
        'query': utterance,
        'timezoneOffset': '0',
        'verbose': 'true',
        'show-all-intents': 'true',
        'spellCheck': 'false',
        'staging': 'false',
        'subscription-key': key
    }

    r = requests.get(f'https://{endpoint}/luis/prediction/v3.0/apps/{appId}/slots/production/predict',headers=headers, params=params)
    print(r.json())

except Exception as e:
    print(f'{e}')
