import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../services/balance_service.dart';
import '../services/scanner_service.dart';

class QrScannerWidget extends StatefulWidget {
  final Function(String?) onScan;
  const QrScannerWidget({required this.onScan, Key? key}) : super(key: key);

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  String? _qrData;
  double? _userBalance;

  @override
  void initState() {
    super.initState();
    ScannerService.subListReset(context.hashCode, reset);
  }

  Future<void> _fetchUserBalance() async {
    double balance = await BalanceService.getUserBalance(ScannerService.getCustomerId(_qrData)!);
    setState(() {
      _userBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        reset();
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: _qrData==null?1:0,
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            if (_qrData!=null)
              qrMessage(),
            Positioned.fill( child: qrTemplate(withCamera: _qrData==null)),
          ],
        ),
      ),
    );
  }

  reset() {
    setState(() {
      _qrData = null;
      _userBalance = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    ScannerService.unsubListReset(context.hashCode);
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    if (_qrData!=null) {
      return;
    }
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_qrData==null) {
        setState(() {
          _qrData = scanData.code;;
          widget.onScan.call(ScannerService.getCustomerId(_qrData));
        });
        _fetchUserBalance();
      }
    });
  }

  bool get isValid => ScannerService.isQrDataValid(_qrData);

  Widget qrMessage() {
    if (isValid) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
          if (_userBalance != null)
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text('${_userBalance?.toStringAsFixed(2)} €', style: TextStyle(fontSize: 18)),
            )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red),
          SizedBox(height: 16),
          Text('Ungültiger QR-Code', style: TextStyle(fontSize: 18, color: Colors.red)),
        ],
      );
    }
  }

  Widget qrTemplate({bool withCamera = false}) {
    double outMargin = 0;
    double thickness = 25;
    double opacity = 0.5;
    Color color = (withCamera?Colors.white:(isValid?Colors.green:Colors.red)).withOpacity(opacity);
    return Container(
        padding: EdgeInsets.all(outMargin),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: thickness),
                  ),
                  child: Visibility(
                    visible: withCamera,
                    child: Center(
                      child: Icon(Icons.qr_code, size: 64, color: color),
                    ),
                  ),
                )
            ),
            Positioned(
              top: (outMargin + thickness * 2),
              left: (outMargin + thickness * 2),
              child: Container(
                width: thickness * 2,
                height: thickness * 2,
                color: color,
              ),
            ),
            Positioned(
              bottom: (outMargin + thickness * 2),
              left: (outMargin + thickness * 2),
              child: Container(
                width: thickness * 2,
                height: thickness * 2,
                color: color,
              ),
            ),

            Positioned(
              top: (outMargin + thickness * 2),
              right: (outMargin + thickness * 2),
              child: Container(
                width: thickness * 2,
                height: thickness * 2,
                color: color,
              ),
            )
          ],
        )
    );
  }
}
