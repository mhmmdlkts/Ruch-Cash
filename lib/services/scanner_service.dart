import 'package:flutter/material.dart';

class ScannerService {
  static Map<int, VoidCallback> onResetList = {};
  static subListReset(int contextId, VoidCallback onReset) {
    onResetList[contextId] = onReset;
  }

  static unsubListReset(int contextId) {
    onResetList.remove(contextId);
  }

  static reset() => onResetList.values.forEach((element) {element.call();});

  static bool isQrDataValid(String? qrData) {
    if (qrData == null) {
      return false;
    }
    return getCustomerId(qrData) != null;
  }

  static String? getCustomerId(String? qrData) {
    if (qrData == null) {
      return null;
    }
    try {
      final uri = Uri.parse(qrData!);
      final customerId = uri.queryParameters['customerId'];
      // print(uri);
      if (customerId == null || customerId.isEmpty) {
        // print('warum?');
        return null;
      }
      return customerId;
    } catch (e) {
      return null;
    }
  }
}