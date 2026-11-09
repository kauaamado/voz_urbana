import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voz_urbana/models/occurrence.dart';
import 'package:voz_urbana/theme/design_system.dart';

import '../helpers/contrast.dart';

void main() {
  test('contrastRatio: preto sobre branco ≈ 21', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
  });

  test('texto secundário tem contraste ≥7:1 (leitura sob sol)', () {
    expect(contrastRatio(DesignSystem.secondary, DesignSystem.background),
        greaterThanOrEqualTo(7.0));
    expect(contrastRatio(DesignSystem.secondary, DesignSystem.surface),
        greaterThanOrEqualTo(7.0));
  });

  test('texto branco sobre primary, success e error tem ≥4,5:1', () {
    for (final fundo in [
      DesignSystem.primary,
      DesignSystem.success,
      DesignSystem.error,
    ]) {
      expect(contrastRatio(Colors.white, fundo), greaterThanOrEqualTo(4.5));
    }
  });

  test('cores de categoria têm ≥3:1 sobre branco', () {
    for (final c in OccurrenceCategory.values) {
      expect(contrastRatio(c.color, Colors.white), greaterThanOrEqualTo(3.0),
          reason: c.label);
    }
  });
}
