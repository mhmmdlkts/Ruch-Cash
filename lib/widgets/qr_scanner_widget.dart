import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../services/balance_service.dart';
import '../services/scanner_service.dart';

class QrScannerWidget extends StatefulWidget {
  final Function(String?) onScan;
  final Function(double?)? onBalanceLoaded;
  final bool collapse;
  const QrScannerWidget({required this.onScan, this.onBalanceLoaded, this.collapse = false, Key? key}) : super(key: key);

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
    if (!isValid) {
      return;
    }
    double balance = await BalanceService.getUserBalance(ScannerService.getCustomerId(_qrData)!);
    _userBalance = balance;
    widget.onBalanceLoaded?.call(balance);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _qrData==null?null:() {
        reset();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          qrView(isVisible: _qrData==null),
          Positioned.fill(
              child: qrTemplate(
                  withCamera: _qrData==null
              )
          ),
        ],
      ),
    );
  }

  reset() {
    setState(() {
      _qrData = null;
      _userBalance = null;
      // widget.onScan.call(null);
    });
  }

  Widget qrView({bool isVisible = true}) => Opacity(
    opacity: isVisible?1:0,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
            child: Container(
              color: Colors.black,
            )
        ),
        QRView(
          key: _qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ],
    ),
  );

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
          _qrData = scanData.code;
          if (isValid) {
            widget.onScan.call(ScannerService.getCustomerId(_qrData));
          } else {
            Future.delayed(Duration(milliseconds: 2000), reset);
          }
        });
        _fetchUserBalance();
      }
    });
  }

  bool get isValid => ScannerService.isQrDataValid(_qrData);

  Widget qrTemplate({bool withCamera = false}) {
    double outMargin = 0;
    double thickness = 25;
    double opacity = 0.5;
    String? message;
    if (_qrData != null) {
      if (isValid) {
        message = _userBalance!=null?'${_userBalance?.toStringAsFixed(2)} €':null;
      } else {
        message = 'Ungültiger QR-Code';
      }
    }
    Color color = (withCamera?Colors.white:(isValid?Colors.green:Colors.red)).withOpacity(opacity);
    Widget messageWidget = Container(
      padding: EdgeInsets.all(10),
      child: Text(message??'', style: TextStyle(fontSize: 20)),
    );
    return Container(
        padding: EdgeInsets.all(outMargin),
        //height: widget.collapse?150:null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: thickness),
                ),
                child: Visibility(
                  visible: true||withCamera,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (message != null)
                          Opacity(opacity: 0, child: messageWidget),
                        if (isCollapsed)
                          Icon(Icons.qr_code, size: 64, color: color),
                        if (message != null)
                          messageWidget
                      ],
                    ),
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
            if (isCollapsed)
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

  bool get isCollapsed => !widget.collapse || !isValid;
}
