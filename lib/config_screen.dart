import 'package:flutter/material.dart';
// Importamos el main para poder saltar al tablero que vive allá
import 'main.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enviarDatosAlESP32() {
    String wifiNombre = _ssidController.text;
    String wifiPassword = _passwordController.text;

    if (wifiNombre.isEmpty || wifiPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena ambos campos de Wi-Fi')),
      );
      return;
    }

    print('Conectando al AP del ESP32...');
    print('Enviando Wi-Fi -> SSID: $wifiNombre, PASS: $wifiPassword');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Conectando ESP32 a la red $wifiNombre...')),
    );

    // Al terminar la configuración inicial del Wi-Fi, mandamos al Tablero con 0.0 litros
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const TableroPrincipal(litrosIniciales: 0.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurar Conexión ESP32',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.wifi_find, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            const Text(
              'Enlazar Wi-Fi del Medidor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa los datos de tu red para que el ESP32 se conecte a internet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Red Wi-Fi
            TextField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Nombre de tu Wi-Fi (SSID)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),

            // Contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña del Wi-Fi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 32),

            // BOTÓN DE ACCIÓN CORREGIDO (Sin el icono erróneo)
            ElevatedButton.icon(
              onPressed: _enviarDatosAlESP32,
              icon: const Icon(Icons.wifi_protected_setup),
              label: const Text('Vincular Red al ESP32'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
