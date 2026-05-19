import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final String? message;
  final bool isOverlay;

  const CustomLoader({
    super.key,
    this.size = 50.0,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: const CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            backgroundColor: AppColors.divider,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          )
        ]
      ],
    );

    if (isOverlay) {
      return Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: AppColors.background.withOpacity(0.4),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: loader,
            ),
          ),
        ],
      );
    }

    return Center(child: loader);
  }
}
