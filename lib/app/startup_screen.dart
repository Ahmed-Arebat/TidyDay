import 'package:flutter/material.dart';

import '../view/widget/brand_mark.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key, this.onRetry});

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
