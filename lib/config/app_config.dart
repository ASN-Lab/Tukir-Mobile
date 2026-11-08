/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  // Backend API (Laravel)
  static const String apiBaseUrl = 'http://192.168.18.212:8000/api';
  static const String socketBaseUrl = 'http://192.168.18.212:8000';

  // MQTT Broker
  static const String mqttBrokerUrl = 'tcp://192.168.18.212:1883';
  static const String mqttClientIdPrefix = 'tukir_mobile_';

  // TTS fallback announcement when hardware audio is unavailable.
  static const String ttsProximityWarning = 'Perhatian: Jarak Dekat';

  // Distance thresholds (cm) as defined by the hardware parking logic.
  static const double carPresentCm = 100.0;
  static const double proximityWarningCm = 30.0;
}
