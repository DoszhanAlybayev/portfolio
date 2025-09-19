import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/price_service.dart';
import '../services/storage_service.dart';
import '../widgets/stock_card.dart';
import '../widgets/stat_card.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Stock> portfolio = [];
  Timer? _timer;
  double usdKzt = 541.27;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
    _updatePrices();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updatePrices();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPortfolio() async {
    final loaded = await StorageService.loadPortfolio();

    setState(() {
      portfolio = [];
    });

    for (int i = 0; i < loaded.length; i++) {
      portfolio.add(loaded[i]);
      _listKey.currentState?.insertItem(i);
    }
  }

  Future<void> _savePortfolio() async {
    await StorageService.savePortfolio(portfolio);
  }

  Future<void> _updatePrices() async {
    try {
      usdKzt = await PriceService.fetchUsdKzt();
      for (var stock in portfolio) {
        double price = await PriceService.fetchPrice(stock.url);
        if (stock.ticker.toUpperCase() == 'TQQQ') {
          stock.currentPrice = price * usdKzt;
        } else {
          stock.currentPrice = price;
        }
      }
      setState(() {});
      _savePortfolio();
    } catch (e) {
      print('Ошибка при обновлении цен: $e');
    }
  }

  double get totalProfit =>
      portfolio.fold(0, (sum, stock) => sum + stock.profitKZT);
  double get totalBuy =>
      portfolio.fold(0, (sum, stock) => sum + stock.totalBuy);
  double get averagePercent =>
      totalBuy > 0 ? (totalProfit / totalBuy) * 100 : 0;

  void _addStockDialog() {
    final tickerController = TextEditingController();
    final urlController = TextEditingController();
    final quantityController = TextEditingController();
    final buyPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Добавить акцию"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tickerController, decoration: const InputDecoration(labelText: "Тикер")),
              TextField(controller: urlController, decoration: const InputDecoration(labelText: "URL")),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: "Количество"), keyboardType: TextInputType.number),
              TextField(controller: buyPriceController, decoration: const InputDecoration(labelText: "Цена покупки (₸)"), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tickerController.text.isEmpty ||
                    urlController.text.isEmpty ||
                    quantityController.text.isEmpty ||
                    buyPriceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Заполни все поля")),
                  );
                  return;
                }

                final stock = Stock(
                  ticker: tickerController.text,
                  url: urlController.text,
                  quantity: int.parse(quantityController.text),
                  buyPrice: double.parse(buyPriceController.text),
                  currentPrice: double.parse(buyPriceController.text),
                );

                setState(() {
                  portfolio.add(stock);
                  _listKey.currentState?.insertItem(portfolio.length - 1);
                });
                _savePortfolio();
                Navigator.pop(ctx);
              },
              child: const Text("Добавить"),
            ),
          ],
        );
      },
    );
  }

  void _showStockOptions(Stock stock, int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Редактировать акцию"),
                onTap: () {
                  Navigator.pop(ctx);
                  _editStockDialog(stock, index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Удалить"),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(stock, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Stock stock, int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Подтверждение"),
          content: Text("Удалить ${stock.ticker}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  portfolio.removeAt(index);
                  _listKey.currentState?.removeItem(
                    index,
                    (context, anim) => StockCard(
                      stock: stock,
                      index: index,
                      animation: anim,
                      onLongPress: _showStockOptions,
                    ),
                    duration: const Duration(milliseconds: 300),
                  );
                });
                _savePortfolio();
              },
              child: const Text("Удалить"),
            ),
          ],
        );
      },
    );
  }

  void _editStockDialog(Stock stock, int index) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Редактировать ${stock.ticker}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Добавить новую покупку:"),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Количество"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Цена за 1 акцию (₸)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () {
                if (quantityController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Заполни все поля")),
                  );
                  return;
                }

                final newQty = int.parse(quantityController.text);
                final newPrice = double.parse(priceController.text);

                final totalOld = stock.buyPrice * stock.quantity;
                final totalNew = newPrice * newQty;
                final newQuantity = stock.quantity + newQty;

                stock.buyPrice = (totalOld + totalNew) / newQuantity;
                stock.quantity = newQuantity;

                setState(() {});
                _savePortfolio();
                Navigator.pop(ctx);
              },
              child: const Text("Сохранить"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    await _updatePrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мой портфель"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatCard(
                title: "Доход",
                value: "${totalProfit.toStringAsFixed(2)} ₸",
                color: totalProfit >= 0 ? Colors.green : Colors.red,
              ),
              StatCard(
                title: "Средний %",
                value: "${averagePercent.toStringAsFixed(2)} %",
                color: averagePercent >= 0 ? Colors.green : Colors.red,
              ),
              StatCard(
                title: "USD/KZT",
                value: usdKzt.toStringAsFixed(2),
                color: Colors.indigo,
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: AnimatedList(
                key: _listKey,
                initialItemCount: portfolio.length,
                itemBuilder: (context, index, animation) {
                  final stock = portfolio[index];
                  return StockCard(
                    stock: stock,
                    index: index,
                    animation: animation,
                    onLongPress: _showStockOptions,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStockDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
