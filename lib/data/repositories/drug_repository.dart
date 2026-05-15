import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database.dart';
import '../models/drug.dart';

class DrugRepository {
  Box<Drug> get _box => DatabaseService.drugsBox;

  ValueListenable<Box<Drug>> listenable() => _box.listenable();

  List<Drug> getAll() {
    final drugs = _box.values.toList();
    drugs.sort((a, b) => a.tradeName.compareTo(b.tradeName));
    return drugs;
  }

  Drug? getById(String id) => _box.get(id);

  Future<void> save(Drug drug) => _box.put(drug.id, drug);

  Future<void> delete(String id) => _box.delete(id);

  Future<Drug> sell(Drug drug, int amount) async {
    final updated = drug.copyWith(quantity: drug.quantity - amount);
    await save(updated);
    return updated;
  }

  List<Drug> filter({
    required String query,
    required String dosageForm,
    required String therapeuticGroup,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return getAll().where((drug) {
      final matchesText =
          normalizedQuery.isEmpty ||
          drug.tradeName.toLowerCase().contains(normalizedQuery) ||
          drug.scientificName.toLowerCase().contains(normalizedQuery) ||
          drug.uses.toLowerCase().contains(normalizedQuery);
      final matchesForm = dosageForm == 'الكل' || drug.dosageForm == dosageForm;
      final matchesGroup =
          therapeuticGroup == 'الكل' ||
          drug.therapeuticGroup == therapeuticGroup;
      return matchesText && matchesForm && matchesGroup;
    }).toList();
  }
}
