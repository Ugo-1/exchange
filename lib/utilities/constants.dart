import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_exchange/utilities/screenutils.dart';

TextStyle kAppName = GoogleFonts.lato(
  fontSize: SizeMg.text(33),
  color: Colors.black,
  fontWeight: FontWeight.bold,
);

TextStyle kCurrencyName = GoogleFonts.openSans(
  fontSize: SizeMg.text(20),
  fontWeight: FontWeight.bold,
);

TextStyle kCurrencyExchange = GoogleFonts.montserratAlternates(
  fontSize: SizeMg.text(23),
  fontWeight: FontWeight.bold,
  color: const Color(0xFF181818),
);

TextStyle kCurrencyExchangeSub = TextStyle(
  fontSize: SizeMg.text(16),
  color: const Color(0xFF7ca591),
  fontWeight: FontWeight.w900,
);

Color kActiveBgColor = const Color(0xFF395368);
Color kInactiveBgColor = Colors.white;
Color kActiveTextColor = Colors.white;
Color kInactiveTextColor = Colors.grey.shade500;