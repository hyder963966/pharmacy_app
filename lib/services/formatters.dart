import 'package:intl/intl.dart';

final _moneyFormatter = NumberFormat.decimalPattern('en_US');

String formatMoney(num value) => '${_moneyFormatter.format(value.round())} ل.س';

String formatQuantity(int value) => _moneyFormatter.format(value);
