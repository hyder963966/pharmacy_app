// مقتطف من أشهر الأسماء التجارية في سوريا
const List<String> syrianDrugs = [
  "Panadol", "Paracetamol", "Revitamin", "Brufen", "Ibuprohm", "Flagyl",
  "Amoxil", "Augmentin", "Ciproxen", "Cefalexin", "Rocephin", "Zinnat",
  "Nidazole", "Daktarin", "Canesten", "Betadine", "Voltaren", "Olfen",
  "Dexamethasone", "Prednisolone", "Ventolin", "Atrovent", "Pulmicort",
  "Loratadine", "Cetirizine", "Fexofenadine", "Ranitidine", "Omeprazole",
  "Gaviscon", "Maalox", "Imodium", "Metoclopramide", "Domperidone",
  "Spasfon", "Buscopan", "No-Spa", "Duspatalin", "Creon", "Festal",
  "Dulcolax", "Lactulose", "Furosimed", "Lasix", "Aldactone", "Concor",
  "Norvasc", "Zestril", "Captopril", "Atacand", "Glucophage", "Diamicron",
  "Insulin", "Synthroid", "Tapazole", "Cortisone", "Methotrexate",
  "Azathioprine", "Erythrosine", "Oradexon", "Sulfate", "Zinc"
];

/// حساب مسافة ليفنشتاين (عدد التعديلات لتحويل a إلى b)
int _levenshtein(String a, String b) {
  a = a.toLowerCase();
  b = b.toLowerCase();
  final costs = List.generate(b.length + 1, (i) => i);
  for (int i = 1; i <= a.length; i++) {
    int prevCost = costs[0];
    costs[0] = i;
    for (int j = 1; j <= b.length; j++) {
      final int insert = costs[j - 1] + 1;
      final int delete = costs[j] + 1;
      final int replace = prevCost + (a[i - 1] == b[j - 1] ? 0 : 1);
      prevCost = costs[j];
      costs[j] = insert < delete ? (insert < replace ? insert : replace) : (delete < replace ? delete : replace);
    }
  }
  return costs[b.length];
}

/// البحث عن أقرب اسم دواء من القائمة
String? fuzzyMatchDrugName(String input) {
  if (input.trim().isEmpty) return null;
  String bestMatch = '';
  int minDistance = 100;
  for (final drug in syrianDrugs) {
    final dist = _levenshtein(input, drug);
    if (dist < minDistance) {
      minDistance = dist;
      bestMatch = drug;
    }
  }
  // نقبل التطابق إذا كان عدد التعديلات أقل من ثلث طول الاسم
  if (minDistance <= input.length / 3) {
    return bestMatch;
  }
  return null;
}