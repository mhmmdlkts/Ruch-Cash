import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rushcash/decoration/colors.dart';
import 'package:rushcash/main.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/models/stand_list.dart';
import 'package:rushcash/services/balance_service.dart';
import 'package:rushcash/services/bazaar_service.dart';
import 'package:rushcash/widgets/qr_scanner_widget.dart';

import '../models/basket.dart';
import '../services/scanner_service.dart';

class SellScreen extends StatefulWidget {
  final StandList standList;
  const SellScreen({required this.standList, Key? key}) : super(key: key);

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String? _scannedUserId;
  bool isLoading = false;
  double? balance;

  @override
  void initState() {
    super.initState();
  }

  void _sellItems() async {
    setState(() {
      isLoading = true;
    });
    if (_scannedUserId != null) {
      await BalanceService.sellItems(_scannedUserId!, widget.standList.stands??[]).then((_) {
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

  Widget _singleElement(Stand stand) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(stand.name??'', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                Text('${stand.price?.toStringAsFixed(2)} €' , style: TextStyle(color: firstColor, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: stand.count <= 0?null:() {
                  setState((){
                    stand.count --;
                  });
                },//copyList[index].count <= 1?_onClickRemove(index):_onClickDec(index),
                child: _getAddRemoveWidget(icon: Icons.remove, bgColor: stand.count > 0?Colors.red.withOpacity(0.6):Colors.grey.withOpacity(0.6), textColor: Colors.white, leftBorder: 5),
              ),
              _getAddRemoveWidget(text: stand.count.toString()/*copyList[index].count.toString()*/, bgColor: firstColor, textColor: Colors.white),
              GestureDetector(
                onTap: () {
                  setState((){
                    stand.count ++;
                  });
                },//_onClickInc(index),
                child: _getAddRemoveWidget(icon: Icons.add, bgColor: Colors.green.withOpacity(0.6), textColor: Colors.white,  rightBorder: 5),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _getAddRemoveWidget({String? text, IconData? icon, Color? bgColor, Color? textColor, double rightBorder=0, double leftBorder=0}) {
    return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(leftBorder), right: Radius.circular(rightBorder)),
        ),
        height: 40,
        width: 40,
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Center(
          child:  text!=null?Text(text, style: TextStyle(color: textColor, fontSize: 20), textAlign: TextAlign.center,):Icon(icon, color: textColor,),
        )
    );
  }

  reset() async {
    ScannerService.reset();
    widget.standList.reset();
    setState(() {
      _scannedUserId = null;
      isLoading = false;
      balance = null;
    });
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      _scannedUserId = null;
      isLoading = false;
      balance = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.standList.name?.toCapitalized()??'No Name'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            ScannerService.reset();
            widget.standList.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: _scannedUserId==null?MediaQuery.of(context).size.width:150,
              child: Container(
                child: QrScannerWidget(
                  onScan: (String? val) {
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
                  }, onBalanceLoaded: (double? b) {
                  setState(() {
                    balance = b;
                  });
                },
                  collapse: true,
                ),
              )
            ),
            Expanded(
              child: Container(
                  child: Stack(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(15),
                            shrinkWrap: true,
                            itemCount: widget.standList.stands!.length,
                            itemBuilder: (_,i) => _singleElement(widget.standList.stands![i]),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.white,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: !canSell() || isLoading?null:_sellItems,
                            child: Container(
                              child: Text('Verkaufen ${widget.standList.price} €'),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  bool canSell() => widget.standList.elementCount > 0 && (balance??0) > (widget.standList.price) ;
}
