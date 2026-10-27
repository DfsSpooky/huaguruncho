import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class ResponsibleUseScreen extends StatelessWidget {
  const ResponsibleUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso de Uso Responsable'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.primaryBlue, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Compromiso de Seguridad y Turismo Sostenible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTermItem(
              title: '1. Carácter Informativo y No Reemplazo de Guías',
              description:
                  'HUAGURUNCHO 360 es una aplicación de orientación y concientización ambiental. No sustituye la contratación de un Guía Oficial de Turismo ni protocolos de alta montaña autorizados por la Municipalidad de Huachón o SERNANP.',
            ),
            _buildTermItem(
              title: '2. Condiciones Climáticas Extremas',
              description:
                  'El Nevado Huaguruncho (5,742 msnm) presenta descensos bruscos de temperatura, tormentas de nieve imprevistas y zonas de grietas. Nunca transite en solitario.',
            ),
            _buildTermItem(
              title: '3. Protección de Lagunas y Ecosistemas',
              description:
                  'Queda estrictamente prohibido arrojar basura, alterar la fauna silvestre (vicuñas, vizcachas) o dañar la flora altoandina (queñuales y puyas). Toda basura generada debe regresar con el visitante.',
            ),
            _buildTermItem(
              title: '4. Eco-Reportes y Emergencias',
              description:
                  'Los eco-reportes sirven para monitoreo y mantenimiento ambiental municipal. En caso de emergencias de salud o rescate inminente, comuníquese directamente con la Policía Nacional (105) o el Centro de Salud de Huachón.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('He leído y comprendido los términos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
