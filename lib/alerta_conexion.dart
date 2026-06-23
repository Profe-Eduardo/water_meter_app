//Este codigo sirve para la parte de alerta cuando no esta conectado
import 'package:flutter/material.dart';

class AlertaConexion extends StatelessWidget {
  final bool visible;

  const AlertaConexion({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    // Si la conexión está activa, el widget no dibuja nada en la pantalla
    if (!visible) return const SizedBox.shrink();

    // Si se pierde la conexión, devuelve el diseño de la alerta
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade400, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.gpp_bad, color: Colors.red.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Alerta! Conexión perdida con el medidor.',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
