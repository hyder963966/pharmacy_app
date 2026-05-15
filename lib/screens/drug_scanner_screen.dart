import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../app.dart';
import '../data/catalogs.dart';

class DrugScannerScreen extends StatefulWidget {
  const DrugScannerScreen({super.key});

  @override
  State<DrugScannerScreen> createState() => _DrugScannerScreenState();
}

class _DrugScannerScreenState extends State<DrugScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _picker = ImagePicker();
  var _barcodeLocked = false;
  String? _capturedImagePath;
  String? _suggestedName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسح الدواء'),
        actions: [
          IconButton(
            tooltip: 'الفلاش',
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'إذا لم يتعرف التطبيق على الباركود، صوّر العلبة لتعبئة الاسم يدوياً أو اختياره من الأسماء الشائعة.',
                      style: TextStyle(height: 1.45),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('صور العلبة'),
                      onPressed: _capturePackage,
                    ),
                    if (_capturedImagePath != null) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _suggestedName,
                        decoration: const InputDecoration(
                          labelText: 'اسم مقترح من العلبة',
                          prefixIcon: Icon(Icons.auto_awesome_rounded),
                        ),
                        items: commonDrugNames
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _suggestedName = value),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('استخدم بيانات العلبة'),
                        onPressed: () {
                          Navigator.of(context).pop({
                            'name': _suggestedName ?? '',
                            'imagePath': _capturedImagePath ?? '',
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_barcodeLocked || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _barcodeLocked = true;
    Navigator.of(context).pop({'barcode': value});
  }

  Future<void> _capturePackage() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null || !mounted) return;
    setState(() {
      _capturedImagePath = image.path;
      _suggestedName = commonDrugNames.first;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SaydalitiApp.teal,
        content: Text(
          'تم حفظ صورة العلبة. اختر الاسم المقترح أو عدّل الحقول لاحقاً.',
        ),
      ),
    );
  }
}
