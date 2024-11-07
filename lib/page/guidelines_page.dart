import 'package:flutter/material.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía para Cuidar el Medio Ambiente'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Misión
            _buildSectionTitle('Misión'),
            _buildSectionContent(
              'Nuestra misión es promover un estilo de vida sostenible y crear conciencia sobre la importancia de cuidar el medio ambiente para las generaciones futuras.',
            ),

            // Visión
            _buildSectionTitle('Visión'),
            _buildSectionContent(
              'Ser un referente en la promoción de prácticas sostenibles y la educación ambiental, contribuyendo al bienestar del planeta y de nuestra comunidad.',
            ),

            // Consejos para cuidar el medio ambiente
            _buildSectionTitle('Consejos para Cuidar el Medio Ambiente'),
            _buildTipsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTipsList() {
    final List<String> tips = [
      '1. Reduce, reutiliza y recicla: Minimiza los residuos usando menos plástico y reutilizando materiales siempre que sea posible.',
      '2. Ahorra agua: Cierra el grifo mientras te cepillas los dientes y opta por duchas más cortas.',
      '3. Usa energía renovable: Considera instalar paneles solares o utilizar energía de fuentes renovables.',
      '4. Planta árboles y plantas: Ayuda a limpiar el aire y proporciona hábitats para la fauna local.',
      '5. Apoya productos locales y sostenibles: Compra en mercados locales y elige productos de empresas que respeten el medio ambiente.',
      '6. Infórmate y educa a otros: Comparte tus conocimientos sobre prácticas sostenibles y la importancia de cuidar el medio ambiente.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips.map((tip) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            tip,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }
}
