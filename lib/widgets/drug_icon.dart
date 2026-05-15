import 'package:flutter/material.dart';

class DrugIcon extends StatelessWidget {
  const DrugIcon({
    super.key,
    required this.form,
    this.size = 46,
    this.highlight = false,
  });

  final String form;
  final double size;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final icon = switch (form) {
      'شراب' => Icons.local_drink_rounded,
      'إبر' => Icons.vaccines_rounded,
      'مراهم' => Icons.spa_rounded,
      'تحاميل' => Icons.medication_liquid_rounded,
      'بخاخ' => Icons.air_rounded,
      'قطرة' => Icons.water_drop_rounded,
      _ => Icons.medication_rounded,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFE8E6) : const Color(0xFFE6F5F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: highlight ? const Color(0xFFB42318) : const Color(0xFF0D6E6E),
        size: size * 0.55,
      ),
    );
  }
}
