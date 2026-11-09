import 'package:flutter/material.dart';

import '../../core/constant/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * .3),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check_rounded, color: Colors.white, size: size * .67),
    );
  }
}
