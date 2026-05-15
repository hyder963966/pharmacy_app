import 'package:flutter/material.dart';

import '../data/catalogs.dart';
import '../data/models/drug.dart';
import '../data/repositories/drug_repository.dart';
import 'drug_scanner_screen.dart';

class AddEditDrugScreen extends StatefulWidget {
  const AddEditDrugScreen({super.key, this.drug});

  final Drug? drug;

  @override
  State<AddEditDrugScreen> createState() => _AddEditDrugScreenState();
}

class _AddEditDrugScreenState extends State<AddEditDrugScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = DrugRepository();
  late final TextEditingController _tradeNameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _scientificNameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _usesController;
  late String _dosageForm;
  late String _therapeuticGroup;
  String? _imagePath;
  var _saving = false;

  bool get _isEditing => widget.drug != null;

  @override
  void initState() {
    super.initState();
    final drug = widget.drug;
    _tradeNameController = TextEditingController(text: drug?.tradeName ?? '');
    _barcodeController = TextEditingController(text: drug?.barcode ?? '');
    _scientificNameController = TextEditingController(
      text: drug?.scientificName ?? '',
    );
    _priceController = TextEditingController(
      text: drug == null ? '' : drug.price.round().toString(),
    );
    _quantityController = TextEditingController(
      text: drug == null ? '' : drug.quantity.toString(),
    );
    _reorderLevelController = TextEditingController(
      text: drug == null ? '5' : drug.reorderLevel.toString(),
    );
    _usesController = TextEditingController(text: drug?.uses ?? '');
    _dosageForm = drug?.dosageForm ?? 'حبوب';
    _therapeuticGroup = drug?.therapeuticGroup ?? 'مسكنات';
    _imagePath = drug?.imagePath;
  }

  @override
  void dispose() {
    _tradeNameController.dispose();
    _barcodeController.dispose();
    _scientificNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _reorderLevelController.dispose();
    _usesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الدواء' : 'إضافة دواء جديد'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.document_scanner_rounded),
                label: const Text('مسح الباركود / تصوير العلبة'),
                onPressed: _openScanner,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                children: [
                  TextFormField(
                    controller: _tradeNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم التجاري *',
                      prefixIcon: Icon(Icons.medication_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'هذا الحقل إجباري'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'الباركود',
                      prefixIcon: Icon(Icons.qr_code_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _scientificNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم العلمي',
                      prefixIcon: Icon(Icons.science_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Section(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _dosageForm,
                    decoration: const InputDecoration(
                      labelText: 'الشكل الصيدلاني',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: dosageFormsForInput
                        .map(
                          (form) =>
                              DropdownMenuItem(value: form, child: Text(form)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _dosageForm = value ?? 'حبوب'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _therapeuticGroup,
                    decoration: const InputDecoration(
                      labelText: 'المجموعة العلاجية',
                      prefixIcon: Icon(Icons.local_hospital_rounded),
                    ),
                    items: therapeuticGroupsForInput
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _therapeuticGroup = value ?? 'مسكنات');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Section(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'السعر',
                            prefixIcon: Icon(Icons.payments_rounded),
                          ),
                          validator: _positiveNumberValidator,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية',
                            prefixIcon: Icon(Icons.inventory_2_rounded),
                          ),
                          validator: _nonNegativeIntValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reorderLevelController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'حد إعادة الطلب',
                      prefixIcon: Icon(Icons.notification_important_rounded),
                    ),
                    validator: _nonNegativeIntValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'الاستعمالات (اختياري)',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('حفظ الدواء'),
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const DrugScannerScreen()),
    );
    if (result == null || !mounted) return;

    setState(() {
      final barcode = result['barcode'];
      final name = result['name'];
      final imagePath = result['imagePath'];
      if (barcode != null && barcode.isNotEmpty) {
        _barcodeController.text = barcode;
      }
      if (name != null &&
          name.isNotEmpty &&
          _tradeNameController.text.isEmpty) {
        _tradeNameController.text = name;
      }
      if (imagePath != null && imagePath.isNotEmpty) {
        _imagePath = imagePath;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final reorderLevel = int.tryParse(_reorderLevelController.text.trim()) ?? 0;
    final current = widget.drug;
    final drug = current == null
        ? Drug(
            tradeName: _tradeNameController.text.trim(),
            barcode: _barcodeController.text.trim(),
            scientificName: _scientificNameController.text.trim(),
            dosageForm: _dosageForm,
            therapeuticGroup: _therapeuticGroup,
            price: price,
            quantity: quantity,
            reorderLevel: reorderLevel,
            uses: _usesController.text.trim(),
            imagePath: _imagePath,
          )
        : current.copyWith(
            tradeName: _tradeNameController.text.trim(),
            barcode: _barcodeController.text.trim(),
            scientificName: _scientificNameController.text.trim(),
            dosageForm: _dosageForm,
            therapeuticGroup: _therapeuticGroup,
            price: price,
            quantity: quantity,
            reorderLevel: reorderLevel,
            uses: _usesController.text.trim(),
            imagePath: _imagePath,
          );

    await _repo.save(drug);
    if (!mounted) return;
    setState(() => _saving = false);
    if (drug.isLowStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${drug.tradeName} وصل إلى حد إعادة الطلب.')),
      );
    }
    Navigator.of(context).pop();
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'أدخل رقماً صحيحاً';
    return null;
  }

  String? _nonNegativeIntValidator(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) return 'أدخل رقماً صحيحاً';
    return null;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EEEB)),
      ),
      child: Column(children: children),
    );
  }
}
