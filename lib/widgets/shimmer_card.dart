import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Shimmer de carregamento para cards de curso.
/// Substitui o conteúdo real enquanto os dados carregam.
class ShimmerCourseCard extends StatefulWidget {
  const ShimmerCourseCard({super.key});

  @override
  State<ShimmerCourseCard> createState() => _ShimmerCourseCardState();
}

class _ShimmerCourseCardState extends State<ShimmerCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Imagem placeholder
              _shimmerBox(
                width: 120,
                height: 120,
                isDark: isDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              const SizedBox(width: 12),
              // Conteúdo placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerBox(
                          width: double.infinity,
                          height: 14,
                          isDark: isDark),
                      const SizedBox(height: 6),
                      _shimmerBox(width: 160, height: 14, isDark: isDark),
                      const Spacer(),
                      _shimmerBox(width: 80, height: 12, isDark: isDark),
                      const SizedBox(height: 4),
                      _shimmerBox(width: 100, height: 12, isDark: isDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
    required double height,
    required bool isDark,
    double? width,
    BorderRadius? borderRadius,
  }) {
    final baseColor = isDark ? const Color(0xFF2A2A2E) : Colors.grey[200]!;
    final highlightColor =
        isDark ? const Color(0xFF3A3A3E) : Colors.grey[100]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (_animation.value - 0.3).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

/// Lista de shimmer cards.
class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const ShimmerCourseCard()),
    );
  }
}
