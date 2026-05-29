import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.kSpaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera decorativa
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: AppConstants.kSpaceXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppConstants.kBorderRadiusCard),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.contact_support_outlined,
                    size: 72,
                    color: AppColors.primaryDark,
                  ),
                  SizedBox(height: AppConstants.kSpaceMD),
                  Text(
                    '¿Cómo podemos ayudarte?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Estamos aquí para resolver tus dudas o escuchar sugerencias.',
                    style: TextStyle(color: AppColors.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.kSpaceLG),

            // Tarjeta de información del desarrollador
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kBorderRadiusCard),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desarrollador',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                    ),
                    const SizedBox(height: AppConstants.kSpaceSM),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.person_pin_outlined,
                          color: AppColors.primaryDark),
                      title: Text('Equipo de Ingeniería Antigravity'),
                      subtitle: Text('Soporte y diseño del Software Core'),
                    ),
                    const Divider(height: AppConstants.kSpaceMD),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.email_outlined,
                          color: AppColors.primaryDark),
                      title: Text('soporte@tienda.com'),
                      subtitle:
                          Text('Responderemos en menos de 24 horas hábiles'),
                    ),
                    const Divider(height: AppConstants.kSpaceMD),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.link_outlined,
                          color: AppColors.primaryDark),
                      title: Text('www.antigravity.dev'),
                      subtitle: Text('Visita nuestro sitio web oficial'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.kSpaceLG),

            // Tarjeta de feedback
            Card(
              elevation: 0,
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kBorderRadiusCard),
                side: const BorderSide(color: AppColors.secondary),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.kSpaceMD),
                child: Column(
                  children: [
                    const Text(
                      'Tu opinión es muy valiosa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: AppConstants.kSpaceXS),
                    const Text(
                      'Si tienes comentarios sobre el rendimiento de la aplicación, el diseño visual o deseas reportar un error, no dudes en escribirnos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: AppConstants.kSpaceMD),
                    ElevatedButton(
                      onPressed: () {
                        // Acción de reporte o envío
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Gracias por tu iniciativa. ¡Nos pondremos en contacto!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onBackground,
                      ),
                      child: const Text('Enviar Comentario'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
