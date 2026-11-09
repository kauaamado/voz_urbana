import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Aviso curto de privacidade com painel explicativo (LGPD).
class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});

  static const _itens = [
    'Ficam públicos: foto, localização, data e categoria.',
    'Não coletamos: nome, conta, telefone ou e-mail.',
    'Evite fotografar rostos e placas de veículos.',
    'O endereço é obtido enviando a localização ao OpenStreetMap (Nominatim); o mapa também é baixado de lá.',
    'Este protótipo não tem servidor próprio: os registros ficam só na memória do aparelho.',
  ];

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacidade e LGPD',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.primary,
                  ),
            ),
            const SizedBox(height: 12),
            for (final item in _itens)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sua publicação é anônima. A foto e a localização ficarão visíveis para todos no mapa.',
          style: TextStyle(color: DesignSystem.secondary, fontSize: 12),
        ),
        TextButton(
          onPressed: () => _showDetails(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, DesignSystem.minTouchTarget),
          ),
          child: const Text('Saiba mais'),
        ),
      ],
    );
  }
}
