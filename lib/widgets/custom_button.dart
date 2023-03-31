import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const CustomButton({required this.label, required this.onTap, Key? key}) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        color: Colors.blue,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Text(widget.label, style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    );
  }
}
