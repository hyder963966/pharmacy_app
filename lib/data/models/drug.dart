import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'drug_adapter.dart';

class Drug {
  Drug({
    String? id,
    this.barcode = '',
    required this.tradeName,
    this.scientificName = '',
    required this.dosageForm,
    required this.therapeuticGroup,
    required this.price,
    required this.quantity,
    required this.reorderLevel,
    this.uses = '',
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String barcode;
  String tradeName;
  String scientificName;
  String dosageForm;
  String therapeuticGroup;
  double price;
  int quantity;
  int reorderLevel;
  String uses;
  String? imagePath;
  final DateTime createdAt;
  DateTime updatedAt;

  bool get isLowStock => quantity <= reorderLevel;

  Drug copyWith({
    String? barcode,
    String? tradeName,
    String? scientificName,
    String? dosageForm,
    String? therapeuticGroup,
    double? price,
    int? quantity,
    int? reorderLevel,
    String? uses,
    String? imagePath,
  }) {
    return Drug(
      id: id,
      barcode: barcode ?? this.barcode,
      tradeName: tradeName ?? this.tradeName,
      scientificName: scientificName ?? this.scientificName,
      dosageForm: dosageForm ?? this.dosageForm,
      therapeuticGroup: therapeuticGroup ?? this.therapeuticGroup,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      uses: uses ?? this.uses,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
