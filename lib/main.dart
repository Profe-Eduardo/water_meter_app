import 'package:flutter/material.dart';
import 'config_screen.dart'; // Importamos la pantalla de internet

void main() {
  runApp(const MiPrimeraApp());
}

class MiPrimeraApp extends StatelessWidget {
  const MiPrimeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Meter App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const PantallaDeCarga(),
    );
  }
}

// ========================================================
// 1. PANTALLA DE CARGA (SPLASH) - DEGRADADO AZUL
// ========================================================
class PantallaDeCarga extends StatefulWidget {
  const PantallaDeCarga({super.key});

  @override
  State<PantallaDeCarga> createState() => _PantallaDeCargaState();
}

class _PantallaDeCargaState extends State<PantallaDeCarga> {
  final TextEditingController _lecturaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarRutaInicial();
  }

  @override
  void dispose() {
    _lecturaController.dispose();
    super.dispose();
  }

  void _verificarRutaInicial() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      // true  -> Configurar Internet (config_screen.dart)
      // false -> Pide lectura inicial aquí y va al tablero
      bool esPrimeraVez = false;

      if (esPrimeraVez) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConfigScreen()),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mostrarDialogoLecturaInicial();
        });
      }
    });
  }

  void _mostrarDialogoLecturaInicial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.speed, color: Colors.blue),
              SizedBox(width: 10),
              Text('Lectura Inicial'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa el valor actual de tu medidor físico:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _lecturaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Litros Iniciales',
                  border: OutlineInputBorder(),
                  suffixText: 'L',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                double lectura =
                    double.tryParse(_lecturaController.text) ?? 0.0;
                Navigator.of(dialogContext).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TableroPrincipal(litrosIniciales: lectura),
                  ),
                );
              },
              child: const Text('Iniciar Tablero'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 120, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'WATER METER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Cargando...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================
// 2. EL TABLERO PRINCIPAL (DASHBOARD)
// ========================================================
class TableroPrincipal extends StatefulWidget {
  final double litrosIniciales;
  const TableroPrincipal({super.key, required this.litrosIniciales});

  @override
  State<TableroPrincipal> createState() => _TableroPrincipalState();
}

class _TableroPrincipalState extends State<TableroPrincipal> {
  late double litrosConsumidos;
  String estadoSensor = "Conectado";

  @override
  void initState() {
    super.initState();
    litrosConsumidos = widget.litrosIniciales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Monitoreo en Vivo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TARJETA DE ESTADO DEL SENSOR
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sensors,
                        size: 30,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dispositivo: ESP32_Server',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Estado: $estadoSensor',
                          style: const TextStyle(
                            fontSize: 16,
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
            const SizedBox(height: 12),

            // TARJETA PRINCIPAL DE CONSUMO TOTAL
            Card(
              elevation: 4,
              shadowColor: Colors.blue.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.waves, size: 50, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'CONSUMO ACUMULADO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${litrosConsumidos.toStringAsFixed(1)} L',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Base inicial física: ${widget.litrosIniciales.toStringAsFixed(1)} L',
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
            ),
            const SizedBox(height: 20),

            // SECCIÓN DE MÉTRICAS DEL DÍA (CORREGIDA CON BLACK87)
            const Text(
              ' Métricas del Día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Consumo Hoy',
                    '15.4 L',
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Flujo Promedio',
                    '4.2 L/m',
                    Icons.speed,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // BOTÓN DE SIMULACIÓN DE FLUJO
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  litrosConsumidos += 1.5;
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 22),
              label: const Text('Simular Pulso de Agua (+1.5L)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
