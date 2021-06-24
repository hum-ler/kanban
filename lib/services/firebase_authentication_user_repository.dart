import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_data.dart';
import 'user_repository.dart';

/// The repository for authentication service using Google Firebase
/// Authentication.
class FirebaseAuthenticationRepository implements UserRepository {
  @override
  Future<void> initRepo() async {
    await Firebase.initializeApp();
  }

  @override
  Future<UserData?> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    return UserData(
      id: user.uid,
      name: user.displayName!,
      email: user.email!,
      isSignedIn: true,
    );
  }

  @override
  Future<UserData?> signIn() async {
    await _signInWithGoogle();

    return getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Signs in the user using Google Authentication provider.
  ///
  /// Copied from https://firebase.flutter.dev/docs/auth/social#google.
  Future<UserCredential> _signInWithGoogle() async {
    if (kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // Or use signInWithRedirect
      // await FirebaseAuth.instance.signInWithRedirect(googleProvider);
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }
}
