import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:pharmacy_app/app.dart';
import 'package:pharmacy_app/data/database.dart';
import 'package:pharmacy_app/data/models/drug.dart';

void main() {
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('saydaliti_test_');
    Hive.init(hiveDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DrugAdapter());
    }
    await Hive.openBox<Drug>(DatabaseService.drugsBoxName);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
  });

  testWidgets('Saydaliti inventory smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SaydalitiApp());

    expect(find.text('صيدليتي'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
