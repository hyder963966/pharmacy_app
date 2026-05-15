import 'package:flutter/material.dart';

import '../app.dart';
import '../data/repositories/drug_repository.dart';
import '../services/reminder_service.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _repo = DrugRepository();
  final _reportService = ReportService();
  final _reminderService = ReminderService();
  var _printing = false;
  var _frequency = 'بدون تذكير';

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والتنبيهات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ReportCard(
              icon: Icons.picture_as_pdf_rounded,
              title: 'طباعة تقرير المخزون',
              subtitle: 'ملف PDF منظم يحتوي أسماء الأدوية والكميات والأسعار.',
              child: ElevatedButton.icon(
                icon: _printing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.print_rounded),
                label: const Text('إنشاء PDF'),
                onPressed: _printing ? null : _printInventory,
              ),
            ),
            const SizedBox(height: 12),
            _ReportCard(
              icon: Icons.show_chart_rounded,
              title: 'تقرير المبيعات اليومية',
              subtitle: 'قيد التطوير، وسيعتمد على سجل البيع اليومي لاحقاً.',
              child: OutlinedButton.icon(
                icon: const Icon(Icons.hourglass_bottom_rounded),
                label: const Text('قيد التطوير'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تقرير المبيعات اليومية قيد التطوير.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _ReportCard(
              icon: Icons.notifications_active_rounded,
              title: 'تذكير الجرد',
              subtitle:
                  'يعرض التطبيق تذكيراً محلياً عند فتحه حسب الفترة المختارة.',
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'بدون تذكير',
                    label: Text('بدون'),
                    icon: Icon(Icons.notifications_off_rounded),
                  ),
                  ButtonSegment(
                    value: 'أسبوعي',
                    label: Text('أسبوعي'),
                    icon: Icon(Icons.date_range_rounded),
                  ),
                  ButtonSegment(
                    value: 'شهري',
                    label: Text('شهري'),
                    icon: Icon(Icons.calendar_month_rounded),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) =>
                    _saveReminder(selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printInventory() async {
    setState(() => _printing = true);
    try {
      await _reportService.printInventoryReport(_repo.getAll());
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _loadReminder() async {
    final frequency = await _reminderService.frequency();
    if (mounted) setState(() => _frequency = frequency);
  }

  Future<void> _saveReminder(String frequency) async {
    await _reminderService.setFrequency(frequency);
    if (!mounted) return;
    setState(() => _frequency = frequency);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم ضبط تذكير الجرد: $frequency')));
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F5F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: SaydalitiApp.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
