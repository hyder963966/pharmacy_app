import 'package:hive_flutter/hive_flutter.dart';

import 'models/drug.dart';

class DatabaseService {
  static const drugsBoxName = 'drugs';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DrugAdapter());
    }
    final box = await Hive.openBox<Drug>(drugsBoxName);
    if (box.isEmpty) {
      await _seed(box);
    }
  }

  static Box<Drug> get drugsBox => Hive.box<Drug>(drugsBoxName);

  static Future<void> _seed(Box<Drug> box) async {
    final samples = [
      Drug(
        barcode: '6210001000012',
        tradeName: 'Panadol Extra',
        scientificName: 'Paracetamol + Caffeine',
        dosageForm: 'حبوب',
        therapeuticGroup: 'مسكنات',
        price: 18500,
        quantity: 24,
        reorderLevel: 8,
        uses: 'مسكن للصداع والآلام الخفيفة وخافض حرارة.',
      ),
      Drug(
        barcode: '6210001000029',
        tradeName: 'Augmentin 625',
        scientificName: 'Amoxicillin + Clavulanic Acid',
        dosageForm: 'حبوب',
        therapeuticGroup: 'مضادات حيوية',
        price: 42000,
        quantity: 5,
        reorderLevel: 6,
        uses: 'مضاد حيوي يستخدم حسب وصفة الطبيب.',
      ),
      Drug(
        barcode: '6210001000036',
        tradeName: 'Ventolin',
        scientificName: 'Salbutamol',
        dosageForm: 'بخاخ',
        therapeuticGroup: 'تنفسية',
        price: 36500,
        quantity: 12,
        reorderLevel: 4,
        uses: 'لتخفيف نوبات ضيق النفس والربو.',
      ),
      Drug(
        barcode: '6210001000043',
        tradeName: 'Omeprazole',
        scientificName: 'Omeprazole',
        dosageForm: 'حبوب',
        therapeuticGroup: 'هضمية',
        price: 14500,
        quantity: 18,
        reorderLevel: 10,
        uses: 'لعلاج الحموضة وارتجاع المعدة.',
      ),
      Drug(
        barcode: '6210001000050',
        tradeName: 'Betadine',
        scientificName: 'Povidone Iodine',
        dosageForm: 'مراهم',
        therapeuticGroup: 'جلدية',
        price: 22000,
        quantity: 3,
        reorderLevel: 5,
        uses: 'مطهر للجروح والاستعمال الخارجي.',
      ),
    ];

    for (final drug in samples) {
      await box.put(drug.id, drug);
    }
  }
}
