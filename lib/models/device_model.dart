import 'package:equatable/equatable.dart';

class DeviceModel extends Equatable {
  final String id;
  final String deviceCode;
  final String deviceName;
  final bool isOnline;
  final String garageStatus; // CLOSED | OPEN
  final String systemMode; // STANDBY | PARKING_IN | EXITING
  final int wifiRssi;

  const DeviceModel({
    required this.id,
    required this.deviceCode,
    required this.deviceName,
    required this.isOnline,
    required this.garageStatus,
    required this.systemMode,
    required this.wifiRssi,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      deviceCode: json['deviceCode'] as String,
      deviceName: json['deviceName'] as String,
      isOnline: json['isOnline'] as bool,
      garageStatus: json['garageStatus'] as String,
      systemMode: json['systemMode'] as String,
      wifiRssi: json['wifiRssi'] as int,
    );
  }

  bool get isGarageOpen => garageStatus.toUpperCase() == 'OPEN';

  DeviceModel copyWith({
    bool? isOnline,
    String? garageStatus,
    String? systemMode,
    int? wifiRssi,
  }) {
    return DeviceModel(
      id: id,
      deviceCode: deviceCode,
      deviceName: deviceName,
      isOnline: isOnline ?? this.isOnline,
      garageStatus: garageStatus ?? this.garageStatus,
      systemMode: systemMode ?? this.systemMode,
      wifiRssi: wifiRssi ?? this.wifiRssi,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deviceCode,
        deviceName,
        isOnline,
        garageStatus,
        systemMode,
        wifiRssi,
      ];
}
