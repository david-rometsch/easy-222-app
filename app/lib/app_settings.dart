import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppSettings {
  static Box get _box => Hive.box('settings');
  static bool get toggleShake => _box.get('toggle_shake') ?? false;
  static set toggleShake(bool val) => _box.put('toggle_shake', val);
  static String get wcaId => _box.get('wca_id') ?? '';
  static set wcaId(String val) => _box.put('wca_id', val);

  static Future<void> init() async {
    await Hive.initFlutter();  // wait until flutter is ready
    await Hive.openBox('settings');
    // create if not existing
    
    if (!_box.containsKey('first_start')) {
      _box.put('wca_id', null);
      _box.put('first_start', true);
      _box.put('toggle_shake', false);
    }

  }
}
