import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tukir_mobile/config/app_colors.dart';
import 'package:tukir_mobile/config/app_config.dart';
import 'package:tukir_mobile/cubit/garage_cubit.dart';
import 'package:tukir_mobile/widgets/parking_visualizer.dart';
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
        title: Text('Asisten Parkir Bus'),
        centerTitle: true,
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
                  Card(
                    color: Color(AppColors.surface),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(device.deviceName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary))),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              StatusBadge(online: device.isOnline),
                              SizedBox(width: 8),
                              Text(device.isOnline ? 'Terhubung' : 'Terputus', style: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // State label
                  if (tel != null)
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(AppColors.secondary).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tel.stateLabel,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(AppColors.primary)),
                        ),
                      ),
                    ),
                  SizedBox(height: 24),

                  // Parking visualizer
                  if (tel != null)
                    ParkingVisualizer(
                      rearDist: tel.rearDistCm, 
                      sideDist: tel.sideDistCm,
                    ),
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
                          backgroundColor: Color(AppColors.primary),
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
                        border: Border.all(color: Color(AppColors.surfaceLight)),
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
