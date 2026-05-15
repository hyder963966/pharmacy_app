import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app.dart';
import '../data/models/drug.dart';
import '../data/repositories/drug_repository.dart';
import '../services/formatters.dart';
import '../widgets/drug_icon.dart';
import 'add_edit_drug_screen.dart';

class DrugDetailScreen extends StatelessWidget {
  DrugDetailScreen({super.key, required this.drugId});

  final String drugId;
  final _repo = DrugRepository();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _repo.listenable(),
      builder: (context, Box<Drug> box, _) {
        final drug = _repo.getById(drugId);
        if (drug == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الدواء')),
            body: const Center(child: Text('تم حذف هذا الدواء.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل الدواء'),
            actions: [
              IconButton(
                tooltip: 'تعديل',
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditDrugScreen(drug: drug),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'حذف',
                icon: const Icon(Icons.delete_rounded),
                onPressed: () => _confirmDelete(context, drug),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _Header(drug: drug),
                const SizedBox(height: 12),
                _InfoGrid(drug: drug),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'دواعي الاستعمال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          drug.uses.isEmpty ? 'غير مذكور' : drug.uses,
                          style: TextStyle(
                            color: drug.uses.isEmpty
                                ? Colors.grey.shade600
                                : Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.point_of_sale_rounded),
                  label: const Text('بيع'),
                  onPressed: () => _sell(context, drug),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sell(BuildContext context, Drug drug) async {
    final controller = TextEditingController(text: '1');
    final amount = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('بيع سريع'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'الكمية المباعة',
              helperText: 'المتوفر حالياً: ${formatQuantity(drug.quantity)}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim()) ?? 0;
                Navigator.of(context).pop(parsed);
              },
              child: const Text('تأكيد البيع'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (amount == null) return;
    if (!context.mounted) return;
    if (amount <= 0 || amount > drug.quantity) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الكمية غير صالحة.')));
      return;
    }

    final updated = await _repo.sell(drug, amount);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated.isLowStock
              ? 'تم البيع. ${updated.tradeName} وصل إلى حد إعادة الطلب.'
              : 'تم خصم الكمية من المخزون.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Drug drug) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدواء'),
        content: Text('هل تريد حذف ${drug.tradeName} من المخزون؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () => Navigator.of(context).pop(true),
            label: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _repo.delete(drug.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.drug});

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EEEB)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              DrugIcon(
                form: drug.dosageForm,
                size: 72,
                highlight: drug.isLowStock,
              ),
              if (drug.imagePath != null)
                Positioned(
                  bottom: -4,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: SaydalitiApp.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drug.tradeName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (drug.scientificName.isNotEmpty)
                  Text(
                    drug.scientificName,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: drug.isLowStock
                        ? const Color(0xFFFFE8E6)
                        : const Color(0xFFE6F5F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    drug.isLowStock ? 'كمية حرجة' : 'المخزون جيد',
                    style: TextStyle(
                      color: drug.isLowStock
                          ? const Color(0xFFB42318)
                          : SaydalitiApp.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.drug});

  final Drug drug;

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem('الباركود', drug.barcode.isEmpty ? 'غير مضاف' : drug.barcode),
      _InfoItem('الكمية الحالية', formatQuantity(drug.quantity)),
      _InfoItem('السعر', formatMoney(drug.price)),
      _InfoItem('الشكل الصيدلاني', drug.dosageForm),
      _InfoItem('المجموعة العلاجية', drug.therapeuticGroup),
      _InfoItem('حد إعادة الطلب', formatQuantity(drug.reorderLevel)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 520;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 3 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: wide ? 2.1 : 1.55,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2EEEB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}
