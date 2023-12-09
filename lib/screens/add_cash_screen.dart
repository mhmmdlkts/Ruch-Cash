import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rushcash/services/balance_service.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/services/person_service.dart';
import 'package:rushcash/widgets/feedback_popup_widget.dart';
import 'package:rushcash/widgets/qr_scanner_widget.dart';

import '../services/scanner_service.dart';

class AddCashScreen extends StatefulWidget {
  const AddCashScreen({Key? key}) : super(key: key);

  @override
  State<AddCashScreen> createState() => _AddCashScreenState();
}

class _AddCashScreenState extends State<AddCashScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? _qrData;
  double? _balance;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => FocusScope.of(context).requestFocus(focusNode));
  }

  Future _onAddCashPressed() async {
    if (isLoading || _qrData == null || !_isFormValid) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      bool isSuccess = await BalanceService.addBalance(_qrData!, inputVal!, BazaarService.bazaar.id!, isLocked: isLocked, context: context);
      if (isSuccess) {

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FeedbackPopupWidget(
              success: true,
              errorTitle: 'Erfolgreich',
              errorMessage: 'Einzahlung erfolgreich',
            );
          },
        );
        reset();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future _onWithdrawCashPressed() async {
    if (isLoading || _qrData == null || !_isFormValid) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      bool isSuccess = await BalanceService.addBalance(_qrData!, -inputVal!, BazaarService.bazaar.id!, context: context);
      if (isSuccess) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FeedbackPopupWidget(
              success: true,
              errorTitle: 'Erfolgreich',
              errorMessage: 'Ausgezahlt erfolgreich.',
            );
          },
        );
        reset();
      } else {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double? get inputVal {
    try {
      return double.parse(_amountController.text.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  reset() {
    setState(() {
      ScannerService.reset();
      isLoading = false;
      _amountController.clear();
      _balance = null;
    });
  }

  void _onMoreThen100() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bitte geben Sie einen Betrag zwischen 0,01 und 100 € ein',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: Text('Add Cash')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(),
          child: Flex(
            direction: isLandscape ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: QrScannerWidget(onScan: (String? val) {
                  if (val == null) {
                    reset();
                    return;
                  }
                  setState(() {
                    _qrData = val;
                  });
                }, onBalanceLoaded: (double? b) {
                  setState((){
                      _balance = b;
                  });
                }),
              ),
              SizedBox(width: isLandscape ? 16.0 : 0, height: isLandscape ? 0 : 16.0),
              if (PersonService.person.role! >= 5  && _qrData != null && _balance == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(isLocked?Icons.lock_outline:Icons.lock_open),
                    Checkbox(
                        value: isLocked,
                        onChanged: (val) {
                          setState(() {
                            isLocked = val??false;
                          });
                        }
                    ),
                    Container(width: 20)
                  ],
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: focusNode,
                    maxLength: 5,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        // Erlauben nur Zahlen mit maximal 2 Dezimalstellen
                        final regExp = RegExp(r'^\d{0,2}(,\d{0,2})?$|^100(,0{0,2})?$');
                        if (regExp.hasMatch(newValue.text)) {
                          return newValue;
                        }
                        _onMoreThen100();
                        return oldValue;
                      }),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      suffixText: '€',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie einen Betrag ein';
                      }
                      // Betrag auf 100€ begrenzen
                      double amount = double.tryParse(value.replaceAll(',', '.')) ?? 0;
                      if (amount <= 0 || amount > 100) {
                        return 'Bitte geben Sie einen Betrag zwischen 0,01 und 100 € ein';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {}); // Aktualisieren des Zustands, um den Button zu aktivieren/deaktivieren
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: inputVal != null && !isLoading && _qrData != null ? ((_balance??0)>= inputVal!? _onWithdrawCashPressed:null) : null,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Ändere die Hintergrundfarbe für Auszahlung
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Text('Auszahlung'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: inputVal != null && !isLoading && _qrData != null ? _onAddCashPressed : null,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Ändere die Hintergrundfarbe für Einzahlung
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Text('Einzahlung'),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}