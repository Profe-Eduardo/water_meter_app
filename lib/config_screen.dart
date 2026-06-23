import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _lecturaController = TextEditingController();

  // 🚀 VARIABLES PARA EL ESCÁNER ESTILO FOCO INTELIGENTE
  bool _buscandoDispositivos = false;
  String? _dispositivoEncontrado;
  bool _esp32ConectadoDirectamente = false;
  final String _esp32ApUrl = 'http://192.168.4.1/datos';

  @override
  void initState() {
    super.initState();
    // Iniciamos un escaneo automático al abrir la pantalla
    _comenzarEscaneoWifi();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _lecturaController.dispose();
    super.dispose();
  }

  // 🔄 MOTOR DE DESCUBRIMIENTO: Intenta hacer un ping al Access Point del ESP32
  Future<void> _comenzarEscaneoWifi() async {
    setState(() {
      _buscandoDispositivos = true;
      _dispositivoEncontrado = null;
      _esp32ConectadoDirectamente = false;
    });

    // Simulamos una pequeña animación de escaneo de 2.5 segundos
    await Future.delayed(const Duration(milliseconds: 2500));

    try {
      // Intentamos conectar con la IP por defecto del modo Access Point del ESP32
      final response = await http.get(Uri.parse(_esp32ApUrl)).timeout(
            const Duration(seconds: 3),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _buscandoDispositivos = false;
          // Si tu ESP32 no manda un nombre, usamos un fallback genérico reconocible
          _dispositivoEncontrado =
              data['dispositivo'] ?? "Medidor Inteligente ESP32";
          _esp32ConectadoDirectamente = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('¡Hardware Water Meter detectado con éxito!')),
        );
      }
    } catch (e) {
      // Si el celular no está conectado al Wi-Fi propio del ESP32, fallará el ping
      setState(() {
        _buscandoDispositivos = false;
        _dispositivoEncontrado = null;
        _esp32ConectadoDirectamente = false;
      });
    }
  }

  void _enviarDatosAlESP32() {
    String wifiNombre = _ssidController.text;
    String wifiPassword = _passwordController.text;
    String lecturaTexto = _lecturaController.text;

    if (wifiNombre.isEmpty || wifiPassword.isEmpty || lecturaTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, llena todos los campos (Wi-Fi y Calibración)'),
        ),
      );
      return;
    }

    double litrosIniciales = double.tryParse(lecturaTexto) ?? 0.0;

    // Aquí meterías tu petición HTTP POST al ESP32 para pasarle las credenciales del Wi-Fi de tu casa
    debugPrint('Enviando SSID: $wifiNombre, PASS: $wifiPassword a la placa.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sincronizando configuración con el medidor...')),
    );

    Navigator.pop(context, litrosIniciales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Vincular Medidor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📡 SECCIÓN INTERACTIVA DE BÚSQUEDA (Estilo Foco Inteligente)
            _buildSeccionEscaneoVisual(),

            const SizedBox(height: 24),
            const Divider(height: 32, thickness: 1.2),

            // Formulario de envío
            const Text(
              'Parámetros de Red Doméstica',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Wi-Fi de tu Casa (SSID)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña del Wi-Fi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Calibración de Flujo',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lecturaController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Lectura Inicial en el Medidor Físico',
                helperText:
                    'El valor de litros que marca el plástico del medidor hoy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
                suffixText: 'L',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _esp32ConectadoDirectamente
                  ? _enviarDatosAlESP32
                  : null, // Deshabilitado si no hay enlace
              icon: const Icon(Icons.settings_input_component_rounded),
              label: const Text('Provisionar Dispositivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔋 COMPONENTE VISUAL DINÁMICO DEL ESCÁNER DE DISPOSITIVOS
  Widget _buildSeccionEscaneoVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          if (_buscandoDispositivos) ...[
            const SizedBox(height: 10),
            const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Buscando hardware Water Meter en la red local...',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ] else if (_esp32ConectadoDirectamente &&
              _dispositivoEncontrado != null) ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.teal.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.wb_incandescent_rounded,
                    color: Colors.teal,
                    size: 28), // Ícono estilo foco/dispositivo listo
              ),
              title: Text(
                _dispositivoEncontrado!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: const Text('Listo para recibir configuración de red',
                  style: TextStyle(color: Colors.green)),
              trailing: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                onPressed: _comenzarEscaneoWifi,
              ),
            ),
          ] else ...[
            // Caso donde no detecta la placa AP
            Column(
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 44, color: Colors.red.shade300),
                const SizedBox(height: 10),
                const Text(
                  'No se detectó ningún medidor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Asegúrate de que tu celular esté conectado a la red Wi-Fi propia generada por el ESP32 para poder provisionarlo.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _comenzarEscaneoWifi,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Reintentar búsqueda'),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
