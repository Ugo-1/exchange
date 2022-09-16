import 'package:currency_exchange/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:currency_exchange/utilities/custom_currency_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:currency_exchange/utilities/custom_datetime_row.dart';
import 'package:currency_exchange/models/exchange_service_impl.dart';
import 'package:currency_exchange/models/timeseries_exchange_model.dart';
import 'package:currency_exchange/utilities/screenutils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

enum DTSelector { day, week, month, month3, year }

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({Key? key}) : super(key: key);

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  bool isLoading = false;

  String baseCurrency = 'NGN';
  String baseFlag = '🇳🇬';
  String targetCurrency = 'USD';
  String targetFlag = '🇺🇸';

  DTSelector datetimeSelect = DTSelector.month;
  String timeSeries = 'past month';

  ExchangeService exchangeService = ExchangeService();
  double? rate = 0.0;
  Map<int, dynamic>? graphRate = {1: 1.0};
  int xMax = 1;
  int xMin = 0;
  double changeRate = 0.0;
  double yMax = 2.0;
  double yMin = 0.0;

  @override
  void initState() {
    graphCall();
    super.initState();
    FlutterNativeSplash.remove();
  }

  void graphCall() async {
    setState(() {
      isLoading = true;
    });
    TimeSeriesExchangeModel timeSeriesExchangeModel =
        await exchangeService.getTimeSeriesExchange(
            end: timeSeries, base: baseCurrency, target: targetCurrency);
    Iterable<int>? keys = timeSeriesExchangeModel.rates?.keys
        .map((value) => DateTime.parse(value).millisecondsSinceEpoch);
    Iterable<dynamic>? values =
        timeSeriesExchangeModel.rates?.values.map((value) => value.target);
    double yLast = values?.last;
    double yFirst = values?.first;
    List<dynamic>? sortedValues = values?.toList();
    sortedValues?.sort();
    Set<dynamic>? sortedSet = sortedValues?.toSet();

    setState(() {
      isLoading = false;
    });

    setState(() {
      rate = yLast;
      graphRate = Map.fromIterables(keys!, values!);
      changeRate = yLast - yFirst;
      xMax = keys.last;
      xMin = keys.first;
      double diff = sortedSet?.elementAt(1) - sortedSet?.elementAt(0);
      yMax = sortedSet?.last + diff;
      yMin = sortedSet?.first - diff;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeMg.init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: Text(
            'Exchange',
            style: kAppName.copyWith(
                fontSize: SizeMg.text(22.0),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Builder(builder: (context) {
          if (isLoading) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeMg.height(7.0),
                    horizontal: SizeMg.width(15.0)),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CountryDropDown(
                            flag: baseFlag,
                            currency: baseCurrency,
                            onSelect: (Currency currency) {
                              setState(() {
                                baseCurrency = currency.code;
                                baseFlag =
                                    CurrencyUtils.currencyToEmoji(currency);
                                graphCall();
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                                FontAwesomeIcons.arrowRightArrowLeft),
                            iconSize: 20.0,
                            onPressed: () {
                              setState(() {
                                String tempBaseCurrency = baseCurrency;
                                baseCurrency = targetCurrency;
                                targetCurrency = tempBaseCurrency;
                                String tempBaseFlag = baseFlag;
                                baseFlag = targetFlag;
                                targetFlag = tempBaseFlag;
                                graphCall();
                              });
                            },
                          ),
                          CountryDropDown(
                            flag: targetFlag,
                            currency: targetCurrency,
                            onSelect: (Currency currency) {
                              setState(() {
                                targetCurrency = currency.code;
                                targetFlag =
                                    CurrencyUtils.currencyToEmoji(currency);
                                graphCall();
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeMg.height(10.0),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: SizeMg.height(25.0)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6EFDC),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: SizeMg.height(15.0),
                            horizontal: SizeMg.width(10.0)),
                        child: Column(
                          children: [
                            Text(
                              '1 $baseCurrency = ${rate?.toStringAsFixed(4)} $targetCurrency',
                              style: kCurrencyExchange,
                            ),
                            Text(
                              '${changeRate.toStringAsFixed(6)} $timeSeries',
                              style: kCurrencyExchangeSub,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeMg.width(3.0)),
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(
                                show: false,
                              ),
                              lineTouchData: LineTouchData(touchTooltipData:
                                  LineTouchTooltipData(getTooltipItems: (list) {
                                return list
                                    .map((e) => LineTooltipItem(
                                        '${e.y}\n${Jiffy.unixFromMillisecondsSinceEpoch(e.x.toInt()).format('yyyy-MM-d')}',
                                        const TextStyle(
                                          color: Colors.white,
                                        )))
                                    .toList();
                              }), getTouchedSpotIndicator: (barData, listDots) {
                                return listDots.map((dots) {
                                  return TouchedSpotIndicatorData(
                                      FlLine(color: Colors.transparent),
                                      FlDotData(show: true));
                                }).toList();
                              }),
                              gridData: FlGridData(
                                drawHorizontalLine: false,
                              ),
                              maxX: datetimeSelect == DTSelector.day
                                  ? xMax + 0.0
                                  : xMax + 86400000,
                              maxY: yMax,
                              minY: yMin,
                              //minX: xMin - 86400000,
                              lineBarsData: [
                                LineChartBarData(
                                  isStrokeCapRound: true,
                                  spots: graphRate?.entries.map((e) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      e.value,
                                    );
                                  }).toList(),
                                  dotData: FlDotData(
                                      show: true,
                                      checkToShowDot: (i, j) {
                                        return i.x == xMax;
                                      },
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 5.0,
                                          color: const Color(0xFFF2994A),
                                        );
                                      }),
                                  color: const Color(0xFF395368),
                                )
                              ],
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    interval: (yMax - yMin) / 4,
                                    reservedSize: 50,
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      return Text(
                                        value < 1.0
                                            ? value.toStringAsFixed(4)
                                            : value.toStringAsPrecision(5),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: SizeMg.text(11.0),
                                          fontWeight: FontWeight.w500,
                                          color: kInactiveTextColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              clipData: FlClipData.all(),
                            ),
                            swapAnimationCurve: Curves.linear,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SizeMg.height(12.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DatetimeSelector(
                              bgColor: datetimeSelect == DTSelector.day
                                  ? kActiveBgColor
                                  : kInactiveBgColor,
                              text: '1D',
                              textColor: datetimeSelect == DTSelector.day
                                  ? kActiveTextColor
                                  : kInactiveTextColor,
                              onTap: () {
                                setState(() {
                                  datetimeSelect = DTSelector.day;
                                  timeSeries = 'yesterday';
                                  graphCall();
                                });
                              }),
                          DatetimeSelector(
                              bgColor: datetimeSelect == DTSelector.week
                                  ? kActiveBgColor
                                  : kInactiveBgColor,
                              text: '1W',
                              textColor: datetimeSelect == DTSelector.week
                                  ? kActiveTextColor
                                  : kInactiveTextColor,
                              onTap: () {
                                setState(() {
                                  datetimeSelect = DTSelector.week;
                                  timeSeries = 'past week';
                                  graphCall();
                                });
                              }),
                          DatetimeSelector(
                              bgColor: datetimeSelect == DTSelector.month
                                  ? kActiveBgColor
                                  : kInactiveBgColor,
                              text: '1M',
                              textColor: datetimeSelect == DTSelector.month
                                  ? kActiveTextColor
                                  : kInactiveTextColor,
                              onTap: () {
                                setState(() {
                                  datetimeSelect = DTSelector.month;
                                  timeSeries = 'past month';
                                  graphCall();
                                });
                              }),
                          DatetimeSelector(
                              bgColor: datetimeSelect == DTSelector.month3
                                  ? kActiveBgColor
                                  : kInactiveBgColor,
                              text: '3M',
                              textColor: datetimeSelect == DTSelector.month3
                                  ? kActiveTextColor
                                  : kInactiveTextColor,
                              onTap: () {
                                setState(() {
                                  datetimeSelect = DTSelector.month3;
                                  timeSeries = 'past 3 months';
                                  graphCall();
                                });
                              }),
                          DatetimeSelector(
                              bgColor: datetimeSelect == DTSelector.year
                                  ? kActiveBgColor
                                  : kInactiveBgColor,
                              text: '1Y',
                              textColor: datetimeSelect == DTSelector.year
                                  ? kActiveTextColor
                                  : kInactiveTextColor,
                              onTap: () {
                                setState(() {
                                  datetimeSelect = DTSelector.year;
                                  timeSeries = 'past year';
                                  graphCall();
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeMg.height(7.0), horizontal: SizeMg.width(15.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CountryDropDown(
                        flag: baseFlag,
                        currency: baseCurrency,
                        onSelect: (Currency currency) {
                          setState(() {
                            baseCurrency = currency.code;
                            baseFlag = CurrencyUtils.currencyToEmoji(currency);
                            graphCall();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.arrowRightArrowLeft),
                        iconSize: 20.0,
                        onPressed: () {
                          setState(() {
                            String tempBaseCurrency = baseCurrency;
                            baseCurrency = targetCurrency;
                            targetCurrency = tempBaseCurrency;
                            String tempBaseFlag = baseFlag;
                            baseFlag = targetFlag;
                            targetFlag = tempBaseFlag;
                            graphCall();
                          });
                        },
                      ),
                      CountryDropDown(
                        flag: targetFlag,
                        currency: targetCurrency,
                        onSelect: (Currency currency) {
                          setState(() {
                            targetCurrency = currency.code;
                            targetFlag =
                                CurrencyUtils.currencyToEmoji(currency);
                            graphCall();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeMg.height(10.0),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: SizeMg.height(25.0)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EFDC),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: SizeMg.height(15.0),
                        horizontal: SizeMg.width(10.0)),
                    child: Column(
                      children: [
                        Text(
                          '1 $baseCurrency = ${rate?.toStringAsFixed(4)} $targetCurrency',
                          style: kCurrencyExchange,
                        ),
                        Text(
                          '${changeRate.toStringAsFixed(6)} $timeSeries',
                          style: kCurrencyExchangeSub,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: SizeMg.width(3.0)),
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(
                            show: false,
                          ),
                          lineTouchData: LineTouchData(touchTooltipData:
                              LineTouchTooltipData(getTooltipItems: (list) {
                            return list
                                .map((e) => LineTooltipItem(
                                    '${e.y}\n${Jiffy.unixFromMillisecondsSinceEpoch(e.x.toInt()).format('yyyy-MM-d')}',
                                    const TextStyle(
                                      color: Colors.white,
                                    )))
                                .toList();
                          }), getTouchedSpotIndicator: (barData, listDots) {
                            return listDots.map((dots) {
                              return TouchedSpotIndicatorData(
                                  FlLine(color: Colors.transparent),
                                  FlDotData(show: true));
                            }).toList();
                          }),
                          gridData: FlGridData(
                            drawHorizontalLine: false,
                          ),
                          maxX: datetimeSelect == DTSelector.day
                              ? xMax + 0.0
                              : xMax + 86400000,
                          maxY: yMax,
                          minY: yMin,
                          //minX: xMin - 86400000,
                          lineBarsData: [
                            LineChartBarData(
                              isStrokeCapRound: true,
                              spots: graphRate?.entries.map((e) {
                                return FlSpot(
                                  e.key.toDouble(),
                                  e.value,
                                );
                              }).toList(),
                              dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (i, j) {
                                    return i.x == xMax;
                                  },
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 5.0,
                                      color: const Color(0xFFF2994A),
                                    );
                                  }),
                              color: const Color(0xFF395368),
                            )
                          ],
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                interval: (yMax - yMin) / 4,
                                reservedSize: 50,
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    value < 1.0
                                        ? value.toStringAsFixed(4)
                                        : value.toStringAsPrecision(5),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: SizeMg.text(11.0),
                                      fontWeight: FontWeight.w500,
                                      color: kInactiveTextColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          clipData: FlClipData.all(),
                        ),
                        swapAnimationCurve: Curves.linear,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeMg.height(12.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DatetimeSelector(
                          bgColor: datetimeSelect == DTSelector.day
                              ? kActiveBgColor
                              : kInactiveBgColor,
                          text: '1D',
                          textColor: datetimeSelect == DTSelector.day
                              ? kActiveTextColor
                              : kInactiveTextColor,
                          onTap: () {
                            setState(() {
                              datetimeSelect = DTSelector.day;
                              timeSeries = 'yesterday';
                              graphCall();
                            });
                          }),
                      DatetimeSelector(
                          bgColor: datetimeSelect == DTSelector.week
                              ? kActiveBgColor
                              : kInactiveBgColor,
                          text: '1W',
                          textColor: datetimeSelect == DTSelector.week
                              ? kActiveTextColor
                              : kInactiveTextColor,
                          onTap: () {
                            setState(() {
                              datetimeSelect = DTSelector.week;
                              timeSeries = 'past week';
                              graphCall();
                            });
                          }),
                      DatetimeSelector(
                          bgColor: datetimeSelect == DTSelector.month
                              ? kActiveBgColor
                              : kInactiveBgColor,
                          text: '1M',
                          textColor: datetimeSelect == DTSelector.month
                              ? kActiveTextColor
                              : kInactiveTextColor,
                          onTap: () {
                            setState(() {
                              datetimeSelect = DTSelector.month;
                              timeSeries = 'past month';
                              graphCall();
                            });
                          }),
                      DatetimeSelector(
                          bgColor: datetimeSelect == DTSelector.month3
                              ? kActiveBgColor
                              : kInactiveBgColor,
                          text: '3M',
                          textColor: datetimeSelect == DTSelector.month3
                              ? kActiveTextColor
                              : kInactiveTextColor,
                          onTap: () {
                            setState(() {
                              datetimeSelect = DTSelector.month3;
                              timeSeries = 'past 3 months';
                              graphCall();
                            });
                          }),
                      DatetimeSelector(
                          bgColor: datetimeSelect == DTSelector.year
                              ? kActiveBgColor
                              : kInactiveBgColor,
                          text: '1Y',
                          textColor: datetimeSelect == DTSelector.year
                              ? kActiveTextColor
                              : kInactiveTextColor,
                          onTap: () {
                            setState(() {
                              datetimeSelect = DTSelector.year;
                              timeSeries = 'past year';
                              graphCall();
                            });
                          }),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        )
    );
  }
}
