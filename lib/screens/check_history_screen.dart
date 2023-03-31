import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rushcash/services/firestore_paths_service.dart';
import 'package:rushcash/widgets/qr_scanner_widget.dart';

import '../services/scanner_service.dart';

class CheckHistoryScreen extends StatefulWidget {
  const CheckHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CheckHistoryScreen> createState() => _CheckHistoryScreenState();
}

class _CheckHistoryScreenState extends State<CheckHistoryScreen> {
  String? _scannedUserId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check History')),
      body: _scannedUserId != null
          ? _buildHistory()
          : QrScannerWidget(onScan: (String? val) {
        if (val == null) {
          reset();
          return;
        }
        setState(() {
          _scannedUserId = val;
        });
      }),
    );
  }

  reset() {
    setState(() {
      _scannedUserId = null;
    });
  }

  Widget _buildHistory() {
    DocumentReference ref = FirestorePathsService.getCustomersDoc(customerKey: _scannedUserId!);

    return FutureBuilder<DocumentSnapshot>(
        future: ref.get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Kontohistorie'));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            double balance = snapshot.data!.get('balance');
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text('${balance.toStringAsFixed(2)} €', style: TextStyle(fontSize: 30.0)),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: ref.collection('history').orderBy('timestamp', descending: true).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Fehler beim Laden der Kontohistorie'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                            DateTime timestamp = data['timestamp'].toDate();
                            double oldBalance = data['oldBalance'];
                            double newBalance = data['newBalance'];
                            String action = data['action'];

                            return ListTile(
                              title: Text('$action: €${(newBalance - oldBalance).toStringAsFixed(2)}'),
                              subtitle: Text('${timestamp.day}.${timestamp.month}.${timestamp
                                  .year}, ${timestamp.hour}:${timestamp.minute} Uhr'),
                            );
                          }).toList(),
                        );
                      }
                  ),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        }
    );
  }
}
