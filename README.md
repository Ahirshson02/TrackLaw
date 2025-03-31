##  TrackLaw

TrackLaw puts the law in front of the people. Using publically available data from Congress, TrackLaw displays current legislation currently being discussed and passed through Congress, as well as its status and who is in charge of it. TrackLaw provides a summary of the bill so that users can get an overview, but also have the option to open of the bill and read it for themselves. The goal of TrackLaw is to put the law in the hands of the people, so that they can review it and form their own opinions, without the risk of media biases.

## Getting Started

This project is a starting point for a Flutter application that follows the
Download the Flutter SDK, should use close to Flutter version 3.27.3, and close to Dart 3.6.1

Clone the GitHub repo into your local IDE
If you have a mac, run first the emulator through Xcode, then run it without debugging.
<p>If you have an andriod run your emulator first then, run without debugging</p>
<p>If "flutter pub get" does not run automatically, run the command.</p>
<p>If you dont have flutter currently downloaded, you can download it <a href = 'https://docs.flutter.dev/release/archive'>
  here
</a></p>




## Functionality

App opens to a landing page that directs users to either sign in or sign up pages, which in turn utilzie Firebase Authentication.
Once signed in, the user is shown a list of bills currently going through the U.S. Congress, as well as some preliminary info about them, such as
title, status, the committee working with it, and how recently its been discussed. Also on this home page is a user icon that opens a drawer for the user to sign out.
The user can tap on a bill card, and are directed to a new screen with more info on the selected bill, such as a summary, the option to read it for themselves in a file viewer,
and a chatbot to ask questions about the bill, powered by Google Gemini.

Some features are shown but not completed, such as the search bar, filter and sort buttons, and saved bills page.

## Technologies Used
<p>Language: Dart</p>
<p>Framework: Flutter</p>
<p>User Auth: Firebase Authentication<p>
<p>APIs: U.S. Congress, Firebase, Google Gemini</p>
<p>AI Chatbot: Google Gemini</p>

Mobile App project for Code Crunch 305 Hackathon
