import 'package:flutter/material.dart';
import 'package:currency_exchange/utilities/constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:currency_exchange/utilities/screenutils.dart';

class CountryDropDown extends StatelessWidget {

  final String flag;
  final String currency;
  final Function(Currency) onSelect;

  const CountryDropDown({Key? key, required this.flag, required this.currency, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: SizeMg.height(8.0), horizontal: SizeMg.width(16.0)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Text(flag, style: kCurrencyName,),
            SizedBox(
              width: SizeMg.width(7.0),
            ),
            Text(currency, style: kCurrencyName,),
            SizedBox(
              width: SizeMg.width(7.0),
            ),
            const Icon(
              FontAwesomeIcons.angleDown,
              size: 20.0,
            ),
          ],
        ),
      ),
      onTap: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showSearchField: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: onSelect,
        );
      },
    );
  }
}
