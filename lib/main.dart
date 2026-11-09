import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controller/auth_bloc.dart';
import 'controller/tasks_bloc.dart';
import 'core/constant/app_theme.dart';
import 'core/services/auth_service.dart';
import 'data/datasource/task_store.dart';
import 'firebase_options.dart';
import 'view/screen/sign_in_screen.dart';
import 'view/screen/tasks_screen.dart';
import 'view/widget/brand_mark.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TidyDayApp());
}

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
            return _StartupScreen(
              onRetry: () => setState(() => _startup = _initialize()),
            );
          }
          if (!snapshot.hasData) return const _StartupScreen();
          return BlocProvider(
            create: (context) =>
                AuthBloc(AuthService(FirebaseAuth.instance))
                  ..add(AuthStarted()),
            child: const _SessionScreen(),
          );
        },
      ),
    );
  }
}

class _SessionScreen extends StatelessWidget {
  const _SessionScreen();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.user?.uid != current.user?.uid,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..removeCurrentSnackBar();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      builder: (context, state) {
        if (state.checking) return const _StartupScreen();
        final user = state.user;
        if (user == null) return SignInScreen(state: state);
        return BlocProvider(
          key: ValueKey(user.uid),
          create: (context) =>
              TasksBloc(TaskStore(FirebaseFirestore.instance, user.uid))
                ..add(WatchTasks()),
          child: TasksScreen(user: user),
        );
      },
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 58),
              const SizedBox(height: 20),
              if (onRetry case final retry?) ...[
                const Text(
                  'Could not open TidyDay.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: retry, child: const Text('Try again')),
              ] else
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    semanticsLabel: 'Opening TidyDay',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
