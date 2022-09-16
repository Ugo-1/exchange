import 'package:flutter/material.dart';
import 'package:currency_exchange/utilities/screenutils.dart';

class DatetimeSelector extends StatelessWidget {

  final Color bgColor;
  final Color textColor;
  final String text;
  final Function() onTap;

  const DatetimeSelector({Key? key, required this.bgColor, required this.text, required this.textColor, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeMg.height(5.0), horizontal: SizeMg.width(10.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: bgColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: SizeMg.text(15.0),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
