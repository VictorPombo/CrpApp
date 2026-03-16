import 'package:flutter/material.dart';

/// Espaçamento e constraints responsivos.
class AppSpacing {
  /// Padding horizontal da tela por breakpoint.
  static EdgeInsets screenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) {
      return const EdgeInsets.symmetric(horizontal: 80, vertical: 24);
    }
    if (w >= 800) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Largura máxima do conteúdo por breakpoint.
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 1140.0;
    if (w >= 800) return 760.0;
    return double.infinity;
  }

  /// Widget wrapper que centraliza e limita largura do conteúdo.
  static Widget constrained({
    required BuildContext context,
    required Widget child,
    bool addPadding = true,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: maxContentWidth(context)),
        child: addPadding
            ? Padding(
                padding: screenPadding(context),
                child: child,
              )
            : child,
      ),
    );
  }
}
