import 'package:flutter/material.dart';
import '../models/stock.dart';
import 'package:flutter/services.dart'; // 👈 для вибрации

class StockCard extends StatefulWidget {
  final Stock stock;
  final int index;
  final Animation<double> animation;
  final Function(Stock, int) onLongPress;

  const StockCard({
    super.key,
    required this.stock,
    required this.index,
    required this.animation,
    required this.onLongPress,
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: GestureDetector(
        onLongPressStart: (_) {
          setState(() => _isPressed = true);

          // 🔥 Лёгкая вибрация при старте удержания
          HapticFeedback.lightImpact();
        },
        onLongPressEnd: (_) {
          setState(() => _isPressed = false);

          // 👉 Вызов твоего колбэка
          widget.onLongPress(widget.stock, widget.index);
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                widget.stock.ticker,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Покупка: ${widget.stock.buyPrice.toStringAsFixed(2)} ₸'),
                  Text('Количество: ${widget.stock.quantity} шт.'),
                  Text(
                    'Доход: ${widget.stock.profitKZT.toStringAsFixed(2)} ₸ '
                        '(${widget.stock.profitPercent.toStringAsFixed(2)}%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.stock.profitKZT >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.stock.currentPrice.toStringAsFixed(2)} ₸',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(
                    widget.stock.profitKZT >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: widget.stock.profitKZT >= 0
                        ? Colors.green
                        : Colors.red,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

