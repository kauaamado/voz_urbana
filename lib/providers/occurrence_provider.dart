import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/occurrence.dart';

class OccurrenceProvider with ChangeNotifier {
  final List<Occurrence> _occurrences = [
    Occurrence(
      title: 'Buraco na via',
      description: 'Asfalto cedeu na rua principal, risco de acidentes.',
      category: OccurrenceCategory.pavimentacao,
      location: const LatLng(-22.5112, -43.1779), // CEFET Petrópolis
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Occurrence(
      title: 'Poste sem luz',
      description: 'Lâmpada queimada há mais de uma semana perto do ponto de ônibus.',
      category: OccurrenceCategory.iluminacaoPublica,
      location: const LatLng(-22.5125, -43.1785),
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Occurrence(
      title: 'Vazamento de água',
      description: 'Cano estourado desperdiçando água potável.',
      category: OccurrenceCategory.saneamento,
      location: const LatLng(-22.5100, -43.1760),
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Occurrence(
      title: 'Praça precisando de reforma',
      description: 'Balanços quebrados e mato alto.',
      category: OccurrenceCategory.lazer,
      location: const LatLng(-22.5130, -43.1750),
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
    )
  ];

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  List<Occurrence> get occurrences {
    List<Occurrence> filtered = List.from(_occurrences);
    
    // Ordenar mais recentes primeiro
    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (_filterStartDate != null && _filterEndDate != null) {
      filtered = filtered.where((o) {
        return o.dateTime.isAfter(_filterStartDate!.subtract(const Duration(days: 1))) &&
               o.dateTime.isBefore(_filterEndDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }
  
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  void addOccurrence(Occurrence occurrence) {
    _occurrences.insert(0, occurrence); // Adiciona no início
    notifyListeners();
  }

  void setFilterDateRange(DateTime start, DateTime end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void clearFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }
}
