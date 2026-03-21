import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.urgent = false});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: urgent
              ? [AppTheme.brandOrange, AppTheme.brandOrange.withOpacity(.86)]
              : [AppTheme.brandBlue, const Color(0xFF16327F)],
        ),
        boxShadow: [
          BoxShadow(
            color: (urgent ? AppTheme.brandOrange : AppTheme.brandBlue)
                .withOpacity(.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
