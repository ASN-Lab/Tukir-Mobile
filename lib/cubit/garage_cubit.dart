import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/device_model.dart';
import '../models/telemetry_model.dart';
import '../repositories/device_repository.dart';
import '../services/socket_service.dart';

abstract class GarageState extends Equatable {
  const GarageState();
  @override
  List<Object?> get props => [];
}

class GarageInitial extends GarageState {}
class GarageLoading extends GarageState {}
class GarageLoaded extends GarageState {
  final List<DeviceModel> devices;
  final DeviceModel selectedDevice;
  final TelemetryModel? telemetry;

  const GarageLoaded(this.devices, this.selectedDevice, this.telemetry);

  @override
  List<Object?> get props => [devices, selectedDevice, telemetry];
}
class GarageError extends GarageState {
  final String message;
  const GarageError(this.message);
  @override
  List<Object?> get props => [message];
}

class GarageCubit extends Cubit<GarageState> {
  final DeviceRepository deviceRepository;
  final SocketService socketService = SocketService();
  Timer? _staleTimer;
  static const _staleTimeout = Duration(seconds: 40);

  GarageCubit(this.deviceRepository) : super(GarageInitial());

  void _resetStaleTimer() {
    _staleTimer?.cancel();
    _staleTimer = Timer(_staleTimeout, () {
      if (isClosed || state is! GarageLoaded) return;
      debugPrint('GarageCubit: Device marked OFFLINE due to stale data timeout');
      final s = state as GarageLoaded;
      final offlineDevice = s.selectedDevice.copyWith(isOnline: false);
      if (!isClosed) emit(GarageLoaded(s.devices, offlineDevice, s.telemetry));
    });
  }

  Future<void> loadDevices() async {
    if (isClosed) return;
    emit(GarageLoading());
    try {
      final devices = await deviceRepository.getDevices();
      if (isClosed) return;
      if (devices.isEmpty) {
        emit(const GarageError('No devices bound to this account'));
        return;
      }
      final selected = devices.first;
      if (isClosed) return;
      emit(GarageLoaded(devices, selected, null));
      
      // Initial status check
      if (selected.isOnline) {
        _resetStaleTimer();
      }

      // Connect socket
      socketService.connect(
        selected.deviceCode,
        (telMap) {
          if (isClosed) return;
          final tel = TelemetryModel.fromJson(selected.deviceCode, telMap);
          if (state is GarageLoaded) {
            final s = state as GarageLoaded;
            final updatedDevice = s.selectedDevice.copyWith(
              isOnline: true,
              garageStatus: tel.garageStatus,
              systemMode: tel.systemMode,
            );
            _resetStaleTimer();
            if (!isClosed) {
              emit(GarageLoaded(s.devices, updatedDevice, tel));
            }
          }
        },
        (status) {
          if (isClosed || state is! GarageLoaded) return;
          final s = state as GarageLoaded;
          final isOnline = status.toUpperCase() == 'ONLINE';
          debugPrint('GarageCubit: Received status event -> $status (isOnline: $isOnline)');
          final updatedDevice = s.selectedDevice.copyWith(isOnline: isOnline);
          if (isOnline) {
            _resetStaleTimer();
          } else {
            _staleTimer?.cancel();
          }
          if (!isClosed) emit(GarageLoaded(s.devices, updatedDevice, s.telemetry));
        },
      );
    } catch (e) {
      if (!isClosed) emit(GarageError(e.toString()));
    }
  }

  Future<void> toggleGarage(String command) async {
    if (state is! GarageLoaded) return;
    final s = state as GarageLoaded;
    try {
      await deviceRepository.controlGarage(s.selectedDevice.id, command);
      // Optimistic update: langsung refleksikan state di UI
      final updated = s.selectedDevice.copyWith(
        garageStatus: command == 'OPEN' ? 'OPEN' : 'CLOSED',
        systemMode: command == 'OPEN' ? s.selectedDevice.systemMode : 'STANDBY',
      );
      if (isClosed) return;
      emit(GarageLoaded(s.devices, updated, s.telemetry));
    } catch (e) {
      if (!isClosed) emit(GarageError(e.toString()));
    }
  }

  Future<void> togglePower(String command) async {
    if (state is! GarageLoaded) return;
    final s = state as GarageLoaded;
    try {
      await deviceRepository.controlPower(s.selectedDevice.id, command);
      final updated = s.selectedDevice.copyWith(
        systemMode: command == 'POWER_ON' ? 'PARKING_IN' : 'STANDBY',
      );
      if (isClosed) return;
      emit(GarageLoaded(s.devices, updated, s.telemetry));
    } catch (e) {
      if (!isClosed) emit(GarageError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _staleTimer?.cancel();
    if (state is GarageLoaded) {
      socketService.disconnect((state as GarageLoaded).selectedDevice.deviceCode);
    }
    return super.close();
  }
}
