import 'package:flutter/material.dart';
import 'package:currency_exchange/view/exchange_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const CurrencyExchange());
}

class CurrencyExchange extends StatelessWidget {
  const CurrencyExchange({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExchangeScreen(),
    );
  }
}
