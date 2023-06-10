import 'package:flutter/material.dart';
import 'package:rushcash/decoration/colors.dart';
import 'package:rushcash/screens/check_history_screen.dart';
import 'package:rushcash/screens/status_screen.dart';
import 'package:rushcash/services/person_service.dart';
import 'package:rushcash/widgets/custom_button.dart';

import '../services/firebase_service.dart';
import 'add_cash_screen.dart';
import 'all_stands_screen.dart';
import 'edit_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rush Cash'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: firstColor
                ),
                child: Text(PersonService.person?.name??'', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent),),
                onTap: () {
                  FirebaseService.signOut();
                },
              ),
            ],
          ),
        ),
        body: ListView(
          children: [
            if (PersonService.person.role! >= 4)
              Wrap(
                children: [
                  _statusButton(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(color: Colors.black.withOpacity(0.5), height: 0),
                  )
                ],
              ),
            if (PersonService.person.role! >= 3)
              Wrap(
                children: [
                    _standsButton(),
                    _addCashButton(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(color: Colors.black.withOpacity(0.5), height: 0),
                    )
                ],
              ),
            if (PersonService.person.role! >= 2)
              Wrap(
                children: [
                    _checkHistory(),
                    _sellButton(),
                ],
              )
          ],
        )
    );
  }

  Widget _sellButton() => Container(
    width: getButtonWidth(2),
    child: CustomButton(label: 'Sell', icon: Icons.sell, onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllStandsScreen(),
          )
      );
    }),
  );

  Widget _addCashButton() => Container(
    width: getButtonWidth(2),
    child: CustomButton(label: 'Add Cash', icon: Icons.attach_money, onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCashScreen(),
          )
      );
    }),
  );

  Widget _checkHistory() => Container(
    width: getButtonWidth(2),
    child: CustomButton(label: 'Check History', icon: Icons.history, onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckHistoryScreen(),
          )
      );
    }),
  );

  Widget _standsButton() => Container(
    width: getButtonWidth(2),
    child: CustomButton(label: 'Stands', icon: Icons.table_bar, onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditScreen(),
          )
      );
    }),
  );

  Widget _statusButton() => Container(
    width: getButtonWidth(1),
    child: CustomButton(label: 'Status', icon: Icons.bar_chart, onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatusScreen(),
          )
      );
    }),
  );

  double getButtonWidth(int times) {
    return (MediaQuery.of(context).size.width / times);
  }
}
