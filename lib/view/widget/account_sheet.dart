import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';
import 'account_avatar.dart';

Future<void> showAccountSheet({
  required BuildContext context,
  required User user,
  required VoidCallback onSignOut,
}) {
  final name = user.displayName?.trim();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your account', style: text.headlineSmall),
              const SizedBox(height: 18),
              Row(
                children: [
                  AccountAvatar(user: user),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name == null || name.isEmpty
                              ? 'Google account'
                              : name,
                          style: text.titleMedium,
                        ),
                        if (user.email case final String email)
                          Text(
                            email,
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  onSignOut();
                },
                icon: const Icon(Icons.logout_rounded, size: 19),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
