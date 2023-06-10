import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rushcash/services/saved_qr_service.dart';

import '../services/balance_service.dart';

class ShowQrCodeScreen extends StatefulWidget {
  final String customerId;
  const ShowQrCodeScreen({required this.customerId, super.key});

  @override
  State<ShowQrCodeScreen> createState() => _ShowQrCodeScreenState();
}

class _ShowQrCodeScreenState extends State<ShowQrCodeScreen> {
  bool isLoading = false;
  double? balance;

  @override
  void initState() {
    super.initState();
    initBalance();
  }

  initBalance() async {
    setState(() {
      isLoading = true;
    });
    if (widget.customerId != null) {
      balance = await BalanceService.getUserBalance(widget.customerId!);
      if (mounted) {
        setState(() { });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerId??''),
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () async {
              await SavedQrService.removeQr();
            },
          )
        ],
      ),
        body: Center(
          child: isLoading?CircularProgressIndicator():ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              if (widget.customerId != null)
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QrImageView(
                        data: 'https://rc.kreiseck.com?customerId=${widget.customerId}',
                        version: QrVersions.auto,
                        size: 300,
                        padding: EdgeInsets.all(0),
                      ),
                      SizedBox(height: 50),
                      if (balance != null)
                      Text('${balance!.toStringAsFixed(2)} €', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading?null:() async {
          await initBalance();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
