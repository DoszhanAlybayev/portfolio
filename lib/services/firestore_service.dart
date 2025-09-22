import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Получаем ссылку на коллекцию портфеля текущего юзера
  CollectionReference get _portfolioCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Пользователь не авторизован");
    return _firestore.collection('users').doc(uid).collection('portfolio');
  }

  /// Загружаем портфель текущего пользователя
  Future<List<Stock>> loadPortfolio() async {
    final snapshot = await _portfolioCollection.get();
    return snapshot.docs
        .map((doc) => Stock.fromJson(doc.data() as Map<String, dynamic>, id: doc.id))
        .toList();
  }

  /// Добавляем новую акцию
  Future<void> addStock(Stock stock) async {
    final docRef = await _portfolioCollection.add(stock.toJson());
    stock.id = docRef.id; // сохраняем id для дальнейших обновлений
  }

  /// Обновляем существующую акцию
  Future<void> updateStock(Stock stock) async {
    await _portfolioCollection.doc(stock.id).update(stock.toJson());
  }

  /// Удаляем акцию
  Future<void> deleteStock(Stock stock) async {
    await _portfolioCollection.doc(stock.id).delete();
  }

  /// Слушаем изменения портфеля в реальном времени
  Stream<List<Stock>> portfolioStream() {
    return _portfolioCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Stock.fromJson(doc.data() as Map<String, dynamic>, id: doc.id))
          .toList();
    });
  }
}
