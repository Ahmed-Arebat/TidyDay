import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/auth_bloc.dart';
import '../../core/constant/app_theme.dart';
import '../widget/brand_mark.dart';
import '../widget/google_sign_in_button.dart';
import '../widget/welcome_illustration.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.state});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              children: [
                Row(
                  children: [
                    const BrandMark(size: 42),
                    const SizedBox(width: 11),
                    Text(
                      'TidyDay',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.65,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const WelcomeIllustration(),
                const SizedBox(height: 28),
                Text(
                  'A little more focus\nfor your day.',
                  style: text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Make a list, set a date, and check things off as you go.',
                  style: text.bodyLarge?.copyWith(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  busy: state.busy,
                  onPressed: () =>
                      context.read<AuthBloc>().add(GoogleSignInPressed()),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Your tasks stay with your account.',
                        textAlign: TextAlign.center,
                        style: text.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
