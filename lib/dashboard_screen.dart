import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  // CORREGIDO: Aquí le decimos a la pantalla que es OBLIGATORIO recibir la lectura inicial
  final double lecturaInicial;

  const DashboardScreen({super.key, required this.lecturaInicial});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Esta variable guardará el conteo total en tiempo real
  late double litrosConsumidos;
  String estadoSensor = "Conectado";

  @override
  void initState() {
    super.initState();
    // 'widget.lecturaInicial' jala el valor que mandamos desde el main.dart
    // y lo asigna como el punto de partida del medidor
    litrosConsumidos = widget.lecturaInicial;
  }

  void simularFlujoAgua() {
    setState(() {
      litrosConsumidos += 1.5; // Suma 1.5L sobre el valor inicial con cada clic
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Monitoreo Water Meter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TARJETA 1: ESTADO DEL SENSOR
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.router, size: 40, color: Colors.teal),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dispositivo: ESP32_Server',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Estado: $estadoSensor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TARJETA 2: LECTURA DE LITROS (MUESTRA EL TOTAL ACUMULADO)
            Card(
              elevation: 6,
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.opacity, size: 60, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      'CONSUMO TOTAL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${litrosConsumidos.toStringAsFixed(1)} L',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Nota al pie para recordarle al usuario desde qué número empezó
                    Text(
                      'Partiendo de la lectura inicial: ${widget.lecturaInicial.toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // BOTÓN PARA SIMULAR PULSOS
            ElevatedButton.icon(
              onPressed: simularFlujoAgua,
              icon: const Icon(Icons.add_circle),
              label: const Text('Simular Pulso de Agua (+1.5L)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '* Al simular el pulso, los datos se registrarían en el archivo de historial.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
