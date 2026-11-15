import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Foto de uma ocorrência: URL (http/https/blob) ou arquivo local.
/// Na web, o image_picker devolve uma URL `blob:`, então tudo vai por rede.
/// Se não carregar, mostra um ícone em vez de lançar exceção.
class OccurrenceImage extends StatelessWidget {
  const OccurrenceImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.semanticLabel = 'Foto da ocorrência',
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget broken(BuildContext context, Object error, StackTrace? stack) =>
        Container(
          height: height,
          width: width,
          color: DesignSystem.tertiary,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: DesignSystem.secondary),
        );

    // Decodifica só o tamanho exibido (uma dimensão, para manter a proporção).
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final int? cacheWidth = (width != null && width!.isFinite)
        ? (width! * dpr).round()
        : null;
    final int? cacheHeight =
        (cacheWidth == null && height != null && height!.isFinite)
        ? (height! * dpr).round()
        : null;

    final image = kIsWeb || path.startsWith('http')
        ? Image.network(
            path,
            height: height,
            width: width,
            fit: fit,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            errorBuilder: broken,
          )
        : Image.file(
            File(path),
            height: height,
            width: width,
            fit: fit,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            errorBuilder: broken,
          );

    return Semantics(image: true, label: semanticLabel, child: image);
  }
}
