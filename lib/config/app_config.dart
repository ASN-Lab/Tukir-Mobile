/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  // Backend API (Laravel)
  static const String apiBaseUrl = 'https://tukir-backend.wasmer.app/api';
  static const String socketBaseUrl = 'https://tukir-backend.wasmer.app';

  // MQTT Broker
  static const String mqttBrokerUrl = 'wss://q3c13c67.ala.asia-southeast1.emqxsl.com:8084/mqtt';
  static const String mqttClientIdPrefix = 'tukir_mobile_';

  // TTS fallback announcement when hardware audio is unavailable.
  static const String ttsProximityWarning = 'Perhatian: Jarak Dekat';

  // Distance thresholds (cm) as defined by the hardware parking logic.
  static const double carPresentCm = 100.0;
  static const double proximityWarningCm = 30.0;
}


