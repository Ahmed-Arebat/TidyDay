import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/auth_bloc.dart';
import '../../core/constant/app_theme.dart';
import '../widget/brand_mark.dart';

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
                const _WelcomeIllustration(),
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
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    foregroundColor: const Color(0xFF1F1F1F),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF747775)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: state.busy
                      ? null
                      : () =>
                            context.read<AuthBloc>().add(GoogleSignInPressed()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.busy)
                        const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Image.asset(
                          'assets/google_g.png',
                          width: 18,
                          height: 18,
                        ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          state.busy ? 'Signing in…' : 'Continue with Google',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
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

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: 184,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -63,
              right: -54,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x448D87FF), width: 28),
                ),
              ),
            ),
            const Positioned(
              left: 22,
              bottom: 19,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFB7B2FF),
                size: 19,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Container(
                  width: 232,
                  padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44312E81),
                        offset: Offset(0, 10),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PreviewRow(checked: true, fraction: .8),
                      SizedBox(height: 10),
                      _PreviewRow(checked: false, fraction: 1),
                      SizedBox(height: 10),
                      _PreviewRow(checked: false, fraction: .63),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.checked, required this.fraction});

  final bool checked;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 22,
          color: checked ? AppColors.primary : const Color(0xFFB9BDE0),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: fraction,
            alignment: Alignment.centerLeft,
            child: Container(
              height: 7,
              decoration: BoxDecoration(
                color: checked ? const Color(0xFFD6D2FC) : AppColors.line,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
