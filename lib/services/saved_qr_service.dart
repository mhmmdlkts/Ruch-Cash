import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedQrService {

  static const String _dataKey = 'savedQrKey';
  static String? qrData;
  static final Map<String, VoidCallback> listeners = {};

  static Future saveQr(String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, data);
    qrData = data;
    _notify();
  }

  static Future removeQr() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_dataKey);
    qrData = null;
    _notify();
  }

  static _notify() {
    listeners.forEach((key, value) {
      value.call();
    });
  }

  static Future initQr() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    qrData = prefs.getString(_dataKey);
  }

  static void listen(String id, VoidCallback voidCallback) {
    listeners[id] = voidCallback;
  }
}