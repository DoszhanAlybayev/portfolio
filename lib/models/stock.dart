class Stock {
  String ticker;
  String url;
  int quantity;
  double buyPrice;
  double currentPrice;

  Stock({
    required this.ticker,
    required this.url,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
  });

  double get profitKZT => (currentPrice - buyPrice) * quantity;
  double get profitPercent => ((currentPrice - buyPrice) / buyPrice) * 100;
  double get totalBuy => buyPrice * quantity;

  Map<String, dynamic> toJson() => {
        "ticker": ticker,
        "url": url,
        "quantity": quantity,
        "buyPrice": buyPrice,
        "currentPrice": currentPrice,
      };

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        ticker: json["ticker"],
        url: json["url"],
        quantity: json["quantity"],
        buyPrice: (json["buyPrice"] as num).toDouble(),
        currentPrice: (json["currentPrice"] as num).toDouble(),
      );
}
