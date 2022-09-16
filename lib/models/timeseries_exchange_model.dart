import 'dart:convert';

TimeSeriesExchangeModel timeSeriesExchangeModelFromJson(String str) => TimeSeriesExchangeModel.fromJson(json.decode(str));

class TimeSeriesExchangeModel {
  TimeSeriesExchangeModel({
    this.endDate,
    this.rates,
    this.startDate,
  });

  DateTime? endDate;
  Map<String, Rate>? rates;
  DateTime? startDate;

  factory TimeSeriesExchangeModel.fromJson(Map<String, dynamic> json) => TimeSeriesExchangeModel(
    endDate: DateTime.parse(json["end_date"]),
    rates: Map.from(json["rates"]).map((k, v) => MapEntry<String, Rate>(k, Rate.fromJson(v))),
    startDate: DateTime.parse(json["start_date"])
  );
}

class Rate {
  Rate({
    this.target,
  });

  double? target;

  factory Rate.fromJson(Map<String, dynamic> json) => Rate(
    target: json.values.elementAt(0).toDouble(),
  );
}
