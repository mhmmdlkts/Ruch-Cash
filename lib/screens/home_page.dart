import 'package:flutter/material.dart';
import 'package:rushcash/screens/check_history_screen.dart';
import 'package:rushcash/screens/status_screen.dart';
import 'package:rushcash/services/person_service.dart';
import 'package:rushcash/widgets/custom_button.dart';

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
        body: ListView(
          children: [
            if (PersonService.person.role! >= 4)
              _statusButton(),
            if (PersonService.person.role! >= 3)
              _editButton(),
            if (PersonService.person.role! >= 2)
              _sellButton(),
            if (PersonService.person.role! >= 3)
              _addCashButton(),
            if (PersonService.person.role! >= 3)
              _checkHistory(),
          ],
        )
    );
  }

  Widget _sellButton() => CustomButton(label: 'Sell', onTap: () {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllStandsScreen(),
        )
    );
  });

  Widget _addCashButton() => CustomButton(label: 'Add Cash', onTap: () {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCashScreen(),
        )
    );
  });

  Widget _checkHistory() => CustomButton(label: 'Check History', onTap: () {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckHistoryScreen(),
        )
    );
  });

  Widget _editButton() => CustomButton(label: 'Edit', onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(),
      )
    );
  });

  Widget _statusButton() => CustomButton(label: 'Status', onTap: () {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatusScreen(),
        )
    );
  });
}
