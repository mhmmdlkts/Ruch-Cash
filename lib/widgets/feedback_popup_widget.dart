import 'package:flutter/material.dart';
import 'dart:async';

class FeedbackPopupWidget extends StatefulWidget {
  final String errorTitle;
  final String errorMessage;
  final bool success;

  FeedbackPopupWidget({this.errorTitle = 'Fehler', required this.errorMessage, this.success = false});

  @override
  _FeedbackPopupWidgetState createState() => _FeedbackPopupWidgetState();
}

class _FeedbackPopupWidgetState extends State<FeedbackPopupWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(Duration(milliseconds: 1000), () {
      if (mounted && widget.success) {
        Navigator.of(context).pop();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.success ? Colors.green : Colors.red,
      title: Text(
        widget.errorTitle,
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        widget.errorMessage,
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        if (!widget.success)
          OutlinedButton(
            child: Text('Schließen'),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }
}
