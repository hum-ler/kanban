# Kanban

A really basic, individual, Kanban board.

## Features

1. Create boards, columns, and cards. Drag-and-drop to move columns and cards.
2. Access boards through the Android app, or on the web using a browser.

## Limitations

1. Online connection is required to load and save boards.
2. Single user.
3. A Google ID is required for signing in.
4. Undo / redo is local, and is gone every time the board or the app is reloaded.

## Build

1. The project is developed using Flutter. Install the Flutter SDK and run `flutter pub get` in your code folder.
2. [Android] Create your own Firebase project and follow the instructions to set up an Android app. You would be instructed to download google-service.json to add to your android/app folder.
3. [Web] In the Firebase project, set up a web app. You would be instructed to include some Javascript code in your project. Copy the given Javascript snippet into the file web/firebase-initialize-app.js. The file should look like this:
```javascript
// firebase-initialize=app.js

let firebaseConfig = {
  apiKey: "<apiKey>",
  authDomain: "<authDomain>",
  projectId: "<projectId>",
  storageBucket: "<storageBucket>",
  messagingSenderId: "<messagingSenderId>",
  appId: "<appId>"
};

firebase.initializeApp(firebaseConfig);
```
4. In your code folder, run `flutter pub run build_runner build` to generate necessary source files.
