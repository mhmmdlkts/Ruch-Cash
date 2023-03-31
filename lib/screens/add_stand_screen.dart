import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rushcash/models/stand.dart';
import 'package:rushcash/widgets/custom_button.dart';

class AddStandScreen extends StatefulWidget {
  const AddStandScreen({Key? key}) : super(key: key);

  @override
  State<AddStandScreen> createState() => _AddStandScreenState();
}

class _AddStandScreenState extends State<AddStandScreen> {
  String? item;
  String? seller;
  double? price;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Stand')),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          TextField(
            decoration: InputDecoration(
                hintText: 'Item'
            ),
            onChanged: (String val) {
              item = val;
            },
          ),
          TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true), // Erlaubt Komma-Zahlen
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}'))], // Erlaubt nur Zahlen mit maximal 2 Nachkommastellen
            decoration: InputDecoration(
              hintText: 'Price',
              suffixText: '€',
            ),
            onChanged: (String val) {
              try {
                price = double.parse(val.replaceAll(',', '.'));
              } catch (e) {}
            },
          ),
          CustomButton(label: 'Save', onTap: () async {
            if (!isValid()) {
              return;
            }
            Stand stand = Stand.create(name: item, price: price);
            await stand.push();
            Navigator.pop(context);
          })
        ],
      ),
    );
  }

  bool isValid() {
    return price != null && item != null;
  }
}
