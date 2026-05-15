import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/drug.dart';
import '../data/repositories/drug_repository.dart';
import 'drug_scanner_screen.dart';
import 'inventory_screen.dart';
final addDrugProvider = ChangeNotifierProvider<AddDrugState>((ref) => AddDrugState());

class AddDrugState extends ChangeNotifier {
  String name = '';
  String genericName = '';
  String barcode = '';
  String dosageForm = 'حبوب';
  String therapeuticGroup = 'مسكنات';
  double price = 0;
  int quantity = 0;
  int reorderLevel = 10;
  String? usage;
  String? imagePath;

  void setFromScanner(Map<String, dynamic> data) {
    if (data.containsKey('barcode')) barcode = data['barcode'];
    if (data.containsKey('name')) name = data['name'];
    notifyListeners();
  }
}

class AddDrugScreen extends ConsumerStatefulWidget {
  const AddDrugScreen({super.key});
  @override
  ConsumerState<AddDrugScreen> createState() => _AddDrugScreenState();
}

class _AddDrugScreenState extends ConsumerState<AddDrugScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addDrugProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دواء جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // زر المسح الذكي
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('مسح الباركود / تصوير العلبة'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DrugScannerScreen()),
                );
                if (result != null) {
                  ref.read(addDrugProvider).setFromScanner(result as Map<String, dynamic>);
                }
              },
            ),
            const SizedBox(height: 20),
            // الحقول
            TextFormField(
              initialValue: state.name,
              decoration: const InputDecoration(labelText: 'الاسم التجاري *'),
              onChanged: (v) => state.name = v,
              validator: (v) => v!.trim().isEmpty ? 'ضروري' : null,
            ),
            TextFormField(
              initialValue: state.barcode,
              decoration: const InputDecoration(labelText: 'الباركود'),
              onChanged: (v) => state.barcode = v,
            ),
            TextFormField(
              initialValue: state.genericName,
              decoration: const InputDecoration(labelText: 'الاسم العلمي'),
              onChanged: (v) => state.genericName = v,
            ),
            DropdownButtonFormField<String>(
              value: state.dosageForm,
              items: const [
                DropdownMenuItem(value: 'حبوب', child: Text('حبوب')),
                DropdownMenuItem(value: 'شراب', child: Text('شراب')),
                DropdownMenuItem(value: 'إبر', child: Text('إبر')),
                DropdownMenuItem(value: 'مراهم', child: Text('مراهم')),
                DropdownMenuItem(value: 'تحاميل', child: Text('تحاميل')),
                DropdownMenuItem(value: 'بخاخ', child: Text('بخاخ')),
                DropdownMenuItem(value: 'قطرة', child: Text('قطرة')),
                DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
              ],
              onChanged: (v) => state.dosageForm = v!,
              decoration: const InputDecoration(labelText: 'الشكل الصيدلاني'),
            ),
            DropdownButtonFormField<String>(
              value: state.therapeuticGroup,
              items: const [
                DropdownMenuItem(value: 'مسكنات', child: Text('مسكنات')),
                DropdownMenuItem(value: 'مضادات حيوية', child: Text('مضادات حيوية')),
                DropdownMenuItem(value: 'هضمية', child: Text('هضمية')),
                DropdownMenuItem(value: 'قلبية', child: Text('قلبية')),
                DropdownMenuItem(value: 'تنفسية', child: Text('تنفسية')),
                DropdownMenuItem(value: 'هرمونية', child: Text('هرمونية')),
                DropdownMenuItem(value: 'فيتامينات', child: Text('فيتامينات')),
                DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
              ],
              onChanged: (v) => state.therapeuticGroup = v!,
              decoration: const InputDecoration(labelText: 'المجموعة العلاجية'),
            ),
            TextFormField(
              initialValue: state.price.toString(),
              decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => state.price = double.tryParse(v) ?? 0,
            ),
            TextFormField(
              initialValue: state.quantity.toString(),
              decoration: const InputDecoration(labelText: 'الكمية'),
              keyboardType: TextInputType.number,
              onChanged: (v) => state.quantity = int.tryParse(v) ?? 0,
            ),
            TextFormField(
              initialValue: state.reorderLevel.toString(),
              decoration: const InputDecoration(labelText: 'حد إعادة الطلب'),
              keyboardType: TextInputType.number,
              onChanged: (v) => state.reorderLevel = int.tryParse(v) ?? 10,
            ),
            TextFormField(
              initialValue: state.usage,
              decoration: const InputDecoration(labelText: 'الاستعمال (اختياري)'),
              maxLines: 2,
              onChanged: (v) => state.usage = v,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final drug = Drug(
                  barcode: state.barcode,
                  name: state.name,
                  genericName: state.genericName,
                  dosageForm: state.dosageForm,
                  therapeuticGroup: state.therapeuticGroup,
                  price: state.price,
                  quantity: state.quantity,
                  reorderLevel: state.reorderLevel,
                  usage: state.usage,
                );
                await ref.read(drugRepoProvider).addDrug(drug);
                ref.invalidate(allDrugsProvider);
                Navigator.pop(context);
              },
              child: const Text('حفظ الدواء'),
            ),
          ],
        ),
      ),
    );
  }
}