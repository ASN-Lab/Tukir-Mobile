import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tukir_mobile/config/app_colors.dart';
import 'package:tukir_mobile/config/app_config.dart';
import 'package:tukir_mobile/cubit/garage_cubit.dart';
import 'package:tukir_mobile/widgets/parking_gauge.dart';
import 'package:tukir_mobile/widgets/status_badge.dart';

class GarageControlScreen extends StatefulWidget {
  const GarageControlScreen({super.key});

  @override
  State<GarageControlScreen> createState() => _GarageControlScreenState();
}

class _GarageControlScreenState extends State<GarageControlScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GarageCubit>().loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      appBar: AppBar(
        backgroundColor: Color(AppColors.surface),
        title: Text('Garasi Anda', style: TextStyle(color: Color(AppColors.textPrimary))),
      ),
      body: BlocBuilder<GarageCubit, GarageState>(
        builder: (context, state) {
          if (state is GarageLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is GarageError) {
            return Center(child: Text(state.message, style: TextStyle(color: Color(AppColors.danger))));
          }
                if (state is! GarageLoaded) {
                  return const SizedBox.shrink();
                }

          final s = state;
          final device = s.selectedDevice;
          final tel = s.telemetry;

          return RefreshIndicator(
            onRefresh: () => context.read<GarageCubit>().loadDevices(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Device name & connection status
                Text(device.deviceName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary))),
                SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(online: device.isOnline),
                    SizedBox(width: 8),
                    Text(device.isOnline ? 'Terhubung' : 'Terputus', style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                  ],
                ),
                SizedBox(height: 32),

                // State label
                if (tel != null)
                  Center(
                    child: Text(
                      tel.stateLabel,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(AppColors.active)),
                    ),
                  ),
                SizedBox(height: 24),

                // Parking visualizer gauge (rear distance)
                if (tel != null && tel.rearDistCm > 0)
                  Center(child: ParkingGauge(distanceCm: tel.rearDistCm, maxCm: AppConfig.carPresentCm)),
                SizedBox(height: 32),

                // Slide button to open/close garage
                Text('Slide untuk mengubah pintu:', style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                SizedBox(height: 12),
                Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => context.read<GarageCubit>().toggleGarage(device.isGarageOpen ? 'CLOSE' : 'OPEN'),
                        backgroundColor: Color(AppColors.active),
                        foregroundColor: Colors.white,
                        icon: device.isGarageOpen ? Icons.lock : Icons.lock_open,
                        label: device.isGarageOpen ? 'Tutup' : 'Buka',
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Color(AppColors.surface),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      device.isGarageOpen ? 'Pintu TERBUKA - Geser ke kanan untuk Tutup' : 'Pintu TERTUTUP - Geser ke kanan untuk Buka',
                      style: TextStyle(color: Color(AppColors.textPrimary), fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Power toggle
                Text('Master Power (Sensor Parkir):', style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.read<GarageCubit>().togglePower('POWER_ON'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.active)),
                        child: Text('ON'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.read<GarageCubit>().togglePower('POWER_OFF'),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.danger)),
                        child: Text('OFF'),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }
}
