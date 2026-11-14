import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.user, this.radius = 22});

  final User user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final name = (user.displayName ?? user.email ?? '').trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.soft,
      foregroundColor: AppColors.primary,
      child: name.isEmpty
          ? Icon(Icons.person_outline_rounded, size: radius)
          : Text(
              String.fromCharCode(name.runes.first).toUpperCase(),
              style: TextStyle(
                fontSize: radius * .8,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
    );
  }
}
