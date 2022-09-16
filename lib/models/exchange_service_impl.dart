import 'package:currency_exchange/models/timeseries_exchange_model.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';


abstract class ExchangeService{

  factory ExchangeService ()=> ExchangeServiceImpl();

  Future<TimeSeriesExchangeModel> getTimeSeriesExchange({required String end, required String base, required String target});
}


class ExchangeServiceImpl implements ExchangeService{
  @override
  Future<TimeSeriesExchangeModel> getTimeSeriesExchange({required String end, required String base, required String target}) async {
    Jiffy dtToday = Jiffy();
    String endDate = dtToday.format('yyyy-MM-dd');
    String startDate = '';
    switch (end) {
      case 'yesterday':
        startDate = dtToday.subtract(days: 1).format('yyyy-MM-dd');
        break;
      case 'past week':
        startDate = dtToday.subtract(days: 7).format('yyyy-MM-dd');
        break;
      case 'past month':
        startDate = dtToday.subtract(months: 1).format('yyyy-MM-dd');
        break;
      case 'past 3 months':
        startDate = dtToday.subtract(months: 3).format('yyyy-MM-dd');
        break;
      case 'past year':
        startDate = dtToday.subtract(years: 1).format('yyyy-MM-dd');
        break;
    }
    Uri url = Uri.parse('https://api.apilayer.com/exchangerates_data/timeseries?start_date=$startDate&end_date=$endDate&base=$base&symbols=$target&apikey=IHQERQD1hklLhDytBddAW06XtuLMH49f');
    http.Response response = await http.get(url);
    return timeSeriesExchangeModelFromJson(response.body);
  }

}