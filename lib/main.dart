import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config.dart';
import 'models/board_catalog.dart';
import 'models/board_data.dart';
import 'models/user_data.dart';
import 'screens/sign_in.dart';
import 'services/board_bloc.dart';
import 'services/board_repository.dart';
import 'services/catalog_bloc.dart';
import 'services/catalog_repository.dart';
// import 'services/cloud_firestore_board_repository.dart';
// import 'services/cloud_firestore_catalog_repository.dart';
// import 'services/firebase_authentication_user_repository.dart';
import 'services/mock_board_repository.dart';
import 'services/mock_catalog_repository.dart';
import 'services/mock_user_repository.dart';
import 'services/user_bloc.dart';
import 'services/user_repository.dart';

void main() => runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UserRepository>(
            create: (_) => MockUserRepository(),
            // create: (_) => FirebaseAuthenticationRepository(),
          ),
          RepositoryProvider<CatalogRepository>(
            create: (_) => MockCatalogRepository(),
            // create: (_) => CloudFirestoreCatalogRepository(),
          ),
          RepositoryProvider<BoardRepository>(
            create: (_) => MockBoardRepository(),
            // create: (_) => CloudFirestoreBoardRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>(
              create: (context) => UserBloc(
                repository: context.read<UserRepository>(),
                initialState: UserData(),
              ),
            ),
            BlocProvider<CatalogBloc>(
              create: (context) => CatalogBloc(
                repository: context.read<CatalogRepository>(),
                userBloc: context.read<UserBloc>(),
                initialState: BoardCatalog(),
              ),
              lazy: false,
            ),
            BlocProvider<BoardBloc>(
              create: (context) => BoardBloc(
                repository: context.read<BoardRepository>(),
                catalogBloc: context.read<CatalogBloc>(),
                initialState: BoardData(),
              ),
              lazy: false,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: [const Locale('en', 'SG')],
            theme: ThemeData(
              primaryColor: defaultAppColor,
              accentColor: defaultAppAccent,
              canvasColor: defaultBoardColor,
              cardColor: defaultBoardColor,
              colorScheme:
                  ColorScheme.light().copyWith(primary: defaultAppColor),
            ),
            home: SignIn(),
          ),
        ),
      ),
    );
