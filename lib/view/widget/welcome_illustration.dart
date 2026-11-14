import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key});

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
