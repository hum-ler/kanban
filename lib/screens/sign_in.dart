import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config.dart';
import '../models/user_data.dart';
import '../services/user_bloc.dart';
import 'app.dart';

/// Prompts the user to sign in.
class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The startup event initializes the Firebase libraries and checks for
    // cached user credentials.
    context.read<UserBloc>().add(UserEvent.startup);

    return BlocBuilder<UserBloc, UserData>(
      builder: (context, data) => data.isSignedIn
          ? KApp()
          : Scaffold(
              appBar: AppBar(title: Text('Welcome to Kanban')),
              body: Ink(
                color: defaultAppColor,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage('assets/images/logo.png'),
                      ),
                      InkWell(
                        child: Image(
                          image: AssetImage(
                            'assets/images/btn_google_signin_light_normal_web.png',
                          ),
                        ),
                        onTap: () =>
                            context.read<UserBloc>().add(UserEvent.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
