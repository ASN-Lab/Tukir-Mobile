import 'package:equatable/equatable.dart';

/// Live telemetry payload from `tukir/{device_code}/telemetry`.
class TelemetryModel extends Equatable {
  final String deviceCode;
  final String garageStatus; // CLOSED | OPEN
  final String systemMode; // STANDBY | PARKING_IN | EXITING
  final int wifiRssi;
  final double rearDistCm;
  final double sideDistCm;

  const TelemetryModel({
    required this.deviceCode,
    required this.garageStatus,
    required this.systemMode,
    required this.wifiRssi,
    required this.rearDistCm,
    required this.sideDistCm,
  });

  factory TelemetryModel.fromJson(String deviceCode, Map<String, dynamic> json) {
    return TelemetryModel(
      deviceCode: deviceCode,
      garageStatus: json['garage_status'] as String? ?? 'CLOSED',
      systemMode: json['system_mode'] as String? ?? 'STANDBY',
      wifiRssi: (json['wifi_rssi'] as num?)?.toInt() ?? 0,
      rearDistCm: (json['rear_dist_cm'] as num?)?.toDouble() ?? 0,
      sideDistCm: (json['side_dist_cm'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Indonesian display label per spec: TERTUTUP / MOBIL MASUK / MOBIL KELUAR.
  String get stateLabel {
    if (garageStatus == 'CLOSED') return 'TERTUTUP';
    return systemMode == 'EXITING' ? 'MOBIL KELUAR' : 'MOBIL MASUK';
  }

  @override
  List<Object?> get props => [deviceCode, garageStatus, systemMode, wifiRssi, rearDistCm, sideDistCm];
}
