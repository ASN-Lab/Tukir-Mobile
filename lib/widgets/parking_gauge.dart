import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_config.dart';

/// 2D gauge showing vehicle distance from garage wall (rear ultrasonic sensor).
class ParkingGauge extends StatelessWidget {
  final double distanceCm;
  final double maxCm;

  const ParkingGauge({required this.distanceCm, required this.maxCm, super.key});

  Color _getColor() {
    if (distanceCm < AppConfig.proximityWarningCm) return Color(AppColors.danger);
    if (distanceCm < AppConfig.carPresentCm / 2) return Color(AppColors.warning);
    return Color(AppColors.active);
  }

  @override
  Widget build(BuildContext context) {
    final normalized = (distanceCm / maxCm).clamp(0.0, 1.0);
    final barHeight = 200.0 * normalized;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 60,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Color(AppColors.surfaceLight)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 60,
              height: barHeight,
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text('${distanceCm.toStringAsFixed(1)} cm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary))),
      ],
    );
  }
}
