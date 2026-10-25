import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ColorNotifier extends StateNotifier<int> {
  ColorNotifier() : super(0) {
    _load();
  }

  final _key = "ColroNotivier";
  final _stroage = FlutterSecureStorage();

  void _load() async {
    try {
      String value = await _stroage.read(key: _key) ?? "0";
      int index = int.tryParse(value) ?? 0;
      state = index;
    } catch (_) {
      // Storage unavailable: keep the default.
    }
  }

  void changeIndex(int index) {
    state = index;
    _stroage.write(key: _key, value: state.toString()).catchError((_) {});
  }
}

final colorNotifierProvider = StateNotifierProvider<ColorNotifier, int>((ref) {
  return ColorNotifier();
});
