import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool online;
  const StatusBadge({required this.online, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: online ? Color(AppColors.active) : Color(AppColors.danger),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        online ? 'Online' : 'Offline',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
