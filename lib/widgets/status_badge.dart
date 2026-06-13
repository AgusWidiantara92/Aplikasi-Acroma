import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;
  final String? customText;

  const StatusBadge({
    Key? key,
    required this.isOnline,
    this.customText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppTheme.success : AppTheme.error;
    final statusText = customText ?? (isOnline ? 'ONLINE' : 'OFFLINE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: AppTheme.neonShadow(color: statusColor, blurRadius: 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
