import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class PriceService {
  static Future<double> fetchPrice(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Mozilla/5.0'},
    );

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final priceElem =
          document.querySelector('[data-test="instrument-price-last"]');
      if (priceElem != null) {
        var raw = priceElem.text.trim();
        raw = raw.replaceAll('\u00A0', '');
        raw = raw.replaceAll(' ', '');
        raw = raw.replaceAll('.', '');
        raw = raw.replaceAll(',', '.');
        return double.parse(raw);
      }
    }
    throw Exception('Не удалось получить цену с $url');
  }

  static Future<double> fetchUsdKzt() async {
    return await fetchPrice('https://ru.investing.com/currencies/usd-kzt');
  }
}
