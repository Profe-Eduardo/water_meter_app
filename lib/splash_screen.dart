//Este codigo es para la parte de actualizacion y la alerta de nueva actualizacion
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ota_update/ota_update.dart';
import 'main.dart'; // 🚀 Esencial para poder despachar el TableroPrincipal

class PantallaDeCarga extends StatefulWidget {
  const PantallaDeCarga({super.key});

  @override
  State<PantallaDeCarga> createState() => _PantallaDeCargaState();
}

class _PantallaDeCargaState extends State<PantallaDeCarga> {
  final String versionActual = "1.1.4";
  String mensajeCarga = "Iniciando servicios...";
  String progresoDescarga = "";
  bool descargando = false;

  @override
  void initState() {
    super.initState();
    _revisarActualizacionesYProcesar();
  }

  Future<void> _revisarActualizacionesYProcesar() async {
    setState(() {
      mensajeCarga = "Buscando actualizaciones...";
    });

    debugPrint('=== DIAGNÓSTICO OTA ===');
    debugPrint('1. Versión asignada en el Celular: "$versionActual"');

    try {
      final url = Uri.parse(
        'https://raw.githubusercontent.com/Profe-Eduardo/water_meter_app/main/version.json',
      );

      debugPrint('2. Intentando conectar por red a: $url');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      debugPrint(
        '3. Código de respuesta HTTP de GitHub: ${response.statusCode}',
      );
      debugPrint('4. Contenido crudo del JSON recibido: ${response.body}');

      if (response.statusCode == 200) {
        final datos = jsonDecode(response.body);
        String ultimaVersion = datos['version'];
        String urlApk = datos['url'];

        debugPrint(
          '5. Comparando: Celular ($versionActual) vs GitHub ($ultimaVersion)',
        );

        if (ultimaVersion != versionActual) {
          debugPrint(
            '6. Resultado: ¡Son diferentes! Abriendo diálogo de actualización.',
          );
          if (!mounted) return;
          _mostrarDialogoActualizacion(urlApk, ultimaVersion);
          return;
        } else {
          debugPrint(
            '6. Resultado: Son versiones idénticas. No se requiere actualizar.',
          );
        }
      } else {
        debugPrint('❌ Error: El servidor no devolvió código 200 de éxito.');
      }
    } catch (e) {
      debugPrint('❌ El proceso de verificación falló por completo: $e');
    }

    debugPrint('7. Pasando directo al tablero principal de la app.');
    debugPrint('=======================');
    _avanzarAlTablero();
  }

  // 🚀 NUEVO DIÁLOGO CORREGIDO Y REDISEÑADO CON ENFOQUE INDUSTRIAL
  void _mostrarDialogoActualizacion(String urlApk, String nuevaVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          clipBehavior: Clip.antiAlias, // Redondeado perfecto para el gradiente
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade700,
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Optimización de Red',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firmware y Telemetría disponible (v$nuevaVersion)',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Este paquete contiene mejoras de estabilidad en la transferencia de lecturas en tiempo real y optimiza el consumo de datos de la interfaz.\n\n¿Deseas sincronizar y desplegar la versión ahora?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _avanzarAlTablero();
              },
              child: Text(
                'Más tarde',
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _ejecutarDescargaOTA(urlApk);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Desplegar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _ejecutarDescargaOTA(String urlApk) {
    setState(() {
      descargando = true;
      mensajeCarga = "Descargando nueva versión...";
      progresoDescarga = "0%";
    });

    try {
      OtaUpdate().execute(urlApk).listen((OtaEvent event) {
        setState(() {
          if (event.status == OtaStatus.DOWNLOADING) {
            progresoDescarga = "${event.value}%";
          } else if (event.status == OtaStatus.INSTALLING) {
            mensajeCarga = "Abriendo instalador...";
            progresoDescarga = "";
          } else if (event.status == OtaStatus.INTERNAL_ERROR ||
              event.status == OtaStatus.DOWNLOAD_ERROR) {
            descargando = false;
            _avanzarAlTablero();
          }
        });
      });
    } catch (e) {
      _avanzarAlTablero();
    }
  }

  void _avanzarAlTablero() {
    if (!mounted) return;
    setState(() {
      mensajeCarga = "Cargando tablero...";
      descargando = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TableroPrincipal(litrosIniciales: 0.0),
        ),
      );
    });
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 120, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'WATER METER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'v$versionActual',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!descargando) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.cloud_download,
                            size: 18, color: Colors.white70),
                      ],
                      const SizedBox(width: 12),
                      Text(
                        mensajeCarga,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (descargando) ...[
                  const SizedBox(height: 25),
                  Text(
                    progresoDescarga,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
