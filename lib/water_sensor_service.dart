import 'dart:convert';
import 'package:http/http.dart' as http;

class WaterSensorService {
  // La IP por defecto del ESP32 en modo Access Point
  final String _baseUrl = 'http://192.168.4.1/datos';

  /// Obtiene los datos en tiempo real desde el ESP32
  Future<Map<String, dynamic>> fetchLiveUpdates() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(
            const Duration(
              seconds: 3,
            ), // Timeout corto para detectar desconexión rápida
          );

      if (response.statusCode == 200) {
        // Si el ESP32 responde con éxito, decodificamos el JSON
        return jsonDecode(response.body);
      } else {
        throw Exception('Error en el servidor del ESP32');
      }
    } catch (e) {
      // Si el ESP32 está apagado o el cel se desconectó del Wi-Fi, lanzamos el error
      throw Exception('No se pudo conectar con el medidor: $e');
    }
  }
}
