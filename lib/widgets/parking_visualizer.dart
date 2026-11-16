import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Interactive 2D visualization of a bus in a parking bay.
class ParkingVisualizer extends StatelessWidget {
  final double rearDist;
  final double sideDist;
  final double maxDist;

  const ParkingVisualizer({
    required this.rearDist,
    required this.sideDist,
    this.maxDist = 100.0,
    super.key,
  });

  Color _getRearColor() {
    if (rearDist < 10) return const Color(AppColors.danger);
    if (rearDist < 25) return const Color(AppColors.warning);
    return const Color(AppColors.active);
  }

  Color _getSideColor() {
    if (sideDist < 8 || sideDist > 16) return const Color(AppColors.warning);
    return const Color(AppColors.active);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(AppColors.surfaceLight).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(AppColors.surfaceLight)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Parking Bay Boundary
          Container(
            width: 160,
            height: 240,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: const Color(AppColors.textSecondary).withOpacity(0.5), width: 2),
                right: BorderSide(color: const Color(AppColors.textSecondary).withOpacity(0.5), width: 2),
                bottom: BorderSide(color: _getRearColor(), width: 4),
              ),
            ),
          ),

          // The Bus (Top-down view)
          Positioned(
            bottom: (rearDist * 2).clamp(10.0, 180.0), // Scale distance to pixels
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Windows/Roof details
                      Positioned(
                        top: 10, left: 10, right: 10,
                        child: Container(height: 30, color: Colors.white.withOpacity(0.2)),
                      ),
                      // "BUS KAMPUS" Text
                      const Center(
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            'BUS KAMPUS',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('${rearDist.toStringAsFixed(1)} cm', 
                  style: TextStyle(color: _getRearColor(), fontWeight: FontWeight.bold, fontSize: 12)
                ),
              ],
            ),
          ),

          // Side Distance Indicator
          Positioned(
            right: 10,
            child: Column(
              children: [
                Icon(Icons.arrow_right_alt, color: _getSideColor()),
                Text('${sideDist.toStringAsFixed(1)} cm', 
                  style: TextStyle(color: _getSideColor(), fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
