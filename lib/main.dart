import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initialize();
  runApp(const SaydalitiApp());
}
