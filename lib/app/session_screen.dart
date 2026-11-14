import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/auth_bloc.dart';
import '../controller/tasks_bloc.dart';
import '../data/datasource/task_store.dart';
import '../view/screen/sign_in_screen.dart';
import '../view/screen/tasks_screen.dart';
import 'startup_screen.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

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
        if (state.checking) return const StartupScreen();
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
