import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/auth_bloc.dart';
import '../core/constant/app_theme.dart';
import '../core/services/auth_service.dart';
import '../firebase_options.dart';
import 'session_screen.dart';
import 'startup_screen.dart';

class TidyDayApp extends StatefulWidget {
  const TidyDayApp({super.key});

  @override
  State<TidyDayApp> createState() => _TidyDayAppState();
}

class _TidyDayAppState extends State<TidyDayApp> {
  late Future<FirebaseApp> _startup = _initialize();

  Future<FirebaseApp> _initialize() {
    return Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TidyDay',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: FutureBuilder<FirebaseApp>(
        future: _startup,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StartupScreen(
              onRetry: () => setState(() => _startup = _initialize()),
            );
          }
          if (!snapshot.hasData) return const StartupScreen();
          return BlocProvider(
            create: (context) =>
                AuthBloc(AuthService(FirebaseAuth.instance))
                  ..add(AuthStarted()),
            child: const SessionScreen(),
          );
        },
      ),
    );
  }
}
