import 'package:shared_preferences/shared_preferences.dart';

class ReminderService {
  static const _frequencyKey = 'inventory_reminder_frequency';
  static const _lastShownKey = 'inventory_reminder_last_shown';

  Future<String> frequency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_frequencyKey) ?? 'بدون تذكير';
  }

  Future<void> setFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frequencyKey, frequency);
  }

  Future<bool> shouldShowReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final frequency = prefs.getString(_frequencyKey) ?? 'بدون تذكير';
    if (frequency == 'بدون تذكير') return false;

    final lastShown = DateTime.tryParse(prefs.getString(_lastShownKey) ?? '');
    if (lastShown == null) return true;

    final days = DateTime.now().difference(lastShown).inDays;
    return frequency == 'أسبوعي' ? days >= 7 : days >= 30;
  }

  Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownKey, DateTime.now().toIso8601String());
  }
}
