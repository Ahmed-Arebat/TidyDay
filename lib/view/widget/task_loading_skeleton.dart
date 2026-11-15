import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/constant/app_theme.dart';

class TaskLoadingSkeleton extends StatelessWidget {
  const TaskLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Loading tasks',
      child: ExcludeSemantics(
        child: Skeletonizer.zone(
          effect: const ShimmerEffect(
            baseColor: AppColors.line,
            highlightColor: Color(0xFFF7F7FC),
            duration: Duration(milliseconds: 1400),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20, 23, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 150, height: 14, uniRadius: 7),
                SizedBox(height: 9),
                Bone(width: 190, height: 38, uniRadius: 10),
                SizedBox(height: 16),
                _ProgressSkeleton(),
                SizedBox(height: 22),
                Row(
                  children: [
                    Bone(width: 48, height: 16, uniRadius: 8),
                    SizedBox(width: 8),
                    Bone(width: 24, height: 20, uniRadius: 10),
                  ],
                ),
                SizedBox(height: 10),
                _TaskCardSkeleton(titleWidth: 176, detailWidth: 112),
                SizedBox(height: 8),
                _TaskCardSkeleton(titleWidth: 224, detailWidth: 142),
                SizedBox(height: 8),
                _TaskCardSkeleton(titleWidth: 148, detailWidth: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Bone(width: 104, height: 14, uniRadius: 7),
                Spacer(),
                Bone(width: 92, height: 12, uniRadius: 6),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Bone(height: 5, uniRadius: 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCardSkeleton extends StatelessWidget {
  const _TaskCardSkeleton({
    required this.titleWidth,
    required this.detailWidth,
  });

  final double titleWidth;
  final double detailWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 16, 15),
        child: Row(
          children: [
            const Bone.circle(size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(width: titleWidth, height: 16, uniRadius: 8),
                  const SizedBox(height: 9),
                  Bone(width: detailWidth, height: 11, uniRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Bone(width: 8, height: 14, uniRadius: 4),
          ],
        ),
      ),
    );
  }
}
