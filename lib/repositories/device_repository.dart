import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/device_model.dart';

class DeviceRepository {
  final Dio _dio;

  DeviceRepository(String accessToken)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );

  Future<List<DeviceModel>> getDevices() async {
    final response = await _dio.get('/devices');
    final list = response.data as List<dynamic>;
    return list.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> controlGarage(String deviceId, String command) async {
    await _dio.post('/devices/$deviceId/control', data: {'command': command});
  }

  Future<void> controlPower(String deviceId, String command) async {
    await _dio.post('/devices/$deviceId/control', data: {'command': command});
  }
}
