import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/services/balance_service.dart';
import 'package:rushcash/widgets/custom_button.dart';
import 'package:rushcash/widgets/qr_scanner_widget.dart';

import '../services/scanner_service.dart';

class SellScreen extends StatefulWidget {
  final Stand stand;
  const SellScreen({required this.stand, Key? key}) : super(key: key);

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String? _scannedUserId;
  int count = 1;
  bool isLoading = false;

  void _sellItems() async {
    setState(() {
      isLoading = true;
    });
    if (_scannedUserId != null) {
      await BalanceService.sellItem(_scannedUserId!, widget.stand, count).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artikel erfolgreich verkauft')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Verkauf: $error')),
        );
      });
      reset();
    }
  }

  reset() {
    ScannerService.reset();
    setState(() {
      _scannedUserId = null;
      count = 1;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sell Item')),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QrScannerWidget(onScan: (String? val) {
              if (val == null) {
                reset();
                return;
              }
              String? userId = val;
              if (userId != null) {
                setState(() {
                  _scannedUserId = userId;
                });
              }
            }),
            if (_scannedUserId != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading||count<=1?null:() {
                            setState(() {
                              count--;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(40),
                            child: Icon(Icons.exposure_minus_1),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(count.toString(), style: TextStyle(fontSize: 30)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isLoading||count>=20?null:() {
                            setState(() {
                              count++;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(40),
                            child: Icon(Icons.exposure_plus_1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading?null:_sellItems,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        child: Text('Verkaufen'),
                      ),
                    ),
                  ],
                )
              ),
          ],
        ),
      ),
    );
  }
}
