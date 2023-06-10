import 'package:flutter/material.dart';
import 'package:rushcash/decoration/colors.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  const CustomButton({required this.label, this.icon, required this.onTap, Key? key}) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: secondColor,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          onTap: widget.onTap,
          child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  if (widget.icon != null)
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(widget.icon, color: Colors.white),
                    ),
                  Text(widget.label, style: TextStyle(color: Colors.white),),
                ],
              )
          )
        ),
      ),
    );
  }
}
