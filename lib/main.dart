import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // 🚀 Requerido para el manejo del Timer periódico
import 'config_screen.dart';
import 'alerta_conexion.dart'; // Importamos tu widget modular
import 'splash_screen.dart'; // 🚀 Importamos la nueva ubicación de la pantalla de carga

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
      home:
          const PantallaDeCarga(), // Sigue levantando aquí, pero ahora viene de splash_screen.dart
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
  double flujoActual = 0.0; // 🚀 NUEVO: Almacena el valor de L/min del ESP32

  String estadoSensor = "Buscando...";
  bool esConectado = false;
  Timer? _timerMonitoreo;

  // 🚀 Dirección unificada del endpoint de datos reales en el ESP32
  final String _esp32Url = 'http://192.168.4.1/datos';

  @override
  void initState() {
    super.initState();
    litrosConsumidos = widget.litrosIniciales;
    _iniciarMonitoreoESP32(); // Lanza el motor en tiempo real
  }

  @override
  void dispose() {
    _timerMonitoreo?.cancel();
    super.dispose();
  }

  // 🚀 MOTOR MEJORADO: Consume los datos reales y gestiona el estado de red simultáneamente
  void _iniciarMonitoreoESP32() {
    // Bajamos el tiempo a 2 segundos para tener actualizaciones más fluidas del sensor
    _timerMonitoreo = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await http.get(Uri.parse(_esp32Url)).timeout(
              const Duration(
                seconds: 2,
              ), // Timeout ajustado para desconexión rápida
            );

        if (response.statusCode == 200) {
          final datos = jsonDecode(response.body);
          if (!mounted) return;
          setState(() {
            esConectado = true;
            estadoSensor = "Conectado";
            // Acumulamos la lectura del sensor sobre la base inicial de calibración de la app
            litrosConsumidos = widget.litrosIniciales +
                (datos['litros_totales'] as num).toDouble();
            flujoActual = (datos['flujo_por_minuto'] as num).toDouble();
          });
        } else {
          _marcarDesconectado();
        }
      } catch (e) {
        _marcarDesconectado();
      }
    });
  }

  void _marcarDesconectado() {
    if (!mounted) return;
    if (esConectado != false) {
      setState(() {
        esConectado = false;
        estadoSensor = "Desconectado";
        flujoActual = 0.0; // Si no hay red, la velocidad cae a cero
      });
    }
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
        backgroundColor: esConectado
            ? Colors.blue.shade800
            : Colors.blueGrey, // Dinámico según red
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              final resultado = await Navigator.push<double>(
                context,
                MaterialPageRoute(builder: (context) => const ConfigScreen()),
              );

              if (resultado != null) {
                setState(() {
                  litrosConsumidos = resultado;
                });
                debugPrint('Tablero actualizado con la lectura: $resultado L');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AlertaConexion(visible: !esConectado),

            // Tarjeta de estado del dispositivo
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
                        color: esConectado
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        esConectado ? Icons.sensors : Icons.sensors_off,
                        size: 30,
                        color: esConectado ? Colors.green : Colors.red,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: esConectado ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tarjeta de consumo acumulado (Datos reales de red)
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
            const Center(
              child: Text(
                'Métricas del Día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Consumo Hoy',
                    '${litrosConsumidos.toStringAsFixed(1)} L', // Muestra el total real en vivo
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Flujo Real',
                    '${flujoActual.toStringAsFixed(1)} L/m', // 🚀 NUEVO: Vinculado al flujo del ESP32
                    Icons.speed,
                    flujoActual > 0 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // SECCIÓN DE SIMULADORES / INTERRUPTORES DE PRUEBA
            Row(
              children: [
                // Simulación manual local de pulso
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        litrosConsumidos += 1.5;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text(
                      'Pulso (+1.5L)',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón interactivo para alternar estados si pruebas sin el chip
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        esConectado = !esConectado;
                        estadoSensor =
                            esConectado ? "Conectado" : "Desconectado";
                      });
                    },
                    icon: Icon(
                      esConectado ? Icons.wifi_off : Icons.wifi,
                      size: 18,
                    ),
                    label: Text(
                      esConectado ? 'Forzar Alerta' : 'Restaurar Red',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: esConectado
                          ? Colors.red.shade800
                          : Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
