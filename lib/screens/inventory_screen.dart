import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app.dart';
import '../data/catalogs.dart';
import '../data/models/drug.dart';
import '../data/repositories/drug_repository.dart';
import '../services/formatters.dart';
import '../services/reminder_service.dart';
import '../widgets/drug_icon.dart';
import 'add_edit_drug_screen.dart';
import 'drug_detail_screen.dart';
import 'reports_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _repo = DrugRepository();
  final _searchController = TextEditingController();
  final _reminderService = ReminderService();
  var _showSearch = false;
  var _query = '';
  var _selectedForm = 'الكل';
  var _selectedGroup = 'الكل';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReminderIfDue());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'بحث',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => setState(() => _showSearch = !_showSearch),
        ),
        title: const Text('صيدليتي'),
        actions: [
          IconButton(
            tooltip: 'التقارير',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'إضافة دواء',
        backgroundColor: SaydalitiApp.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddEditDrugScreen()));
        },
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _repo.listenable(),
          builder: (context, Box<Drug> box, _) {
            final drugs = _repo.filter(
              query: _query,
              dosageForm: _selectedForm,
              therapeuticGroup: _selectedGroup,
            );
            final lowCount = _repo.getAll().where((d) => d.isLowStock).length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_showSearch) ...[
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText:
                                  'ابحث باسم الدواء أو الاستعمال مثل: صداع',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _InventorySummary(
                          total: box.length,
                          lowStock: lowCount,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dosageForms.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final form = dosageForms[index];
                              return ChoiceChip(
                                label: Text(form),
                                selected: _selectedForm == form,
                                selectedColor: SaydalitiApp.mint,
                                side: const BorderSide(
                                  color: Color(0xFFD7E8E5),
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedForm = form);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGroup,
                          decoration: const InputDecoration(
                            labelText: 'المجموعة العلاجية',
                            prefixIcon: Icon(Icons.category_rounded),
                          ),
                          items: therapeuticGroups
                              .map(
                                (group) => DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedGroup = value ?? 'الكل');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (drugs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyInventory(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.separated(
                      itemCount: drugs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _DrugCard(
                          drug: drugs[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DrugDetailScreen(drugId: drugs[index].id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showReminderIfDue() async {
    if (!mounted || !await _reminderService.shouldShowReminder()) return;
    await _reminderService.markShown();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'موعد تذكير الجرد. راجع الكميات الحرجة قبل نهاية الدوام.',
        ),
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({required this.total, required this.lowStock});

  final int total;
  final int lowStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SaydalitiApp.teal,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/saydaliti_logo.jpg',
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إدارة مخزون الصيدلية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$total دواء محفوظ محلياً · $lowStock كمية حرجة',
                  style: const TextStyle(
                    color: Color(0xFFE6F5F0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.offline_bolt_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  const _DrugCard({required this.drug, required this.onTap});

  final Drug drug;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DrugIcon(form: drug.dosageForm, highlight: drug.isLowStock),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            drug.tradeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (drug.isLowStock)
                          const Icon(
                            Icons.error_rounded,
                            color: Color(0xFFB42318),
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${drug.therapeuticGroup} · ${drug.dosageForm}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TinyPill(
                          icon: Icons.inventory_2_rounded,
                          text: 'الكمية ${formatQuantity(drug.quantity)}',
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _TinyPill(
                            icon: Icons.payments_rounded,
                            text: formatMoney(drug.price),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: SaydalitiApp.teal),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SaydalitiApp.teal, size: 15),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: SaydalitiApp.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_liquid_rounded,
              size: 58,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'لا توجد أدوية مطابقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'غيّر البحث أو أضف دواء جديداً من زر الإضافة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
