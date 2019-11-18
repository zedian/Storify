# Storify - Codejam 2019

https://www.youtube.com/watch?v=SEH8tkEyL84&feature=youtu.be
> Watch the video! And open the sound!

## Inspiration

Coming up with ideas can be challenging when you want to write quality stories . This is where Storify comes in. Using language models for text generation and sentiment-based music recommendations, our app is the perfect companion for writers of all genres. 

## What it does

Storify works in 2 ways:

1. Storify analyzes the user's input to generate 3 context-based text suggestions at a time. The user can then add a recommendation to their text by simply clicking on it.

2. Whenever users click on the Spotify logo that is located in the bottom right corner of the textfield, Storify analyzes the user input to classify the mood of the input. The mood is then used to provide appropriate musical recommendations that suit the text.

> Both services allow effortless writing for both amateur and experienced users.

## How we built it

We built our front-end iOS app using Swift, Storyboards, and primarily Cocoatouch classes. The app uses Firebase to have real-time changes to allow collaboration. The spotify-sdk for iOS was used to be able to remotely control spotify from our app. The back-end was written with python. We made two APIs using flask, one for querying the spotify api, the other for text generation.

## Challenges we ran into

None of us had worked with the Spotify API so it was quite challenging to determine to integrate it into our project. With the release of Swift 5 and ios 13, UIScene was used. Originally, we wanted to use SwiftUI the new framework however, it kept crashing Xcode which led us to return back to using storyboards.  Moreover, some features were made to were unavailable or different in its uses compared to Swift 4.2. 

For the backend, we also encountered quite a lot of difficulties working with the Spotify API, especially for authentication.

## Accomplishments that we're proud of

We're proud to have come up with this idea and to have built a user friendly platform for writing, which we could use personally in the future.

## What I learned
Spotify-ios-sdk, Firestore, Pytorch 

## What's next for Storify

Currently, we do not restrain the text generator and simply let it run wild, it could be interesting to run a similarity analysis on the given text and the generated text to output the most relevant recommendation

Also, we could try to minimize the number of API calls used to make our app faster and more efficient.
