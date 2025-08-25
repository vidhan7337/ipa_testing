import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tax_model.dart';

class TaxProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<TaxModel> _taxs = [];
  List<TaxModel> get taxs => _taxs;

  Future<void> loadtaxs(String uid) async {
    final snapshot = await _firestore.collection('users/$uid/taxs').get();
    _taxs = snapshot.docs.map((doc) => TaxModel.fromDocument(doc)).toList();
    notifyListeners();
  }

  Future<void> addtax(String uid, TaxModel tax) async {
    final ref = await _firestore
        .collection('users/$uid/taxs')
        .add(tax.toDocument());
    tax.id = ref.id;
    _taxs.add(tax);
    notifyListeners();
  }

  Future<void> updatetax(String uid, TaxModel tax) async {
    await _firestore
        .collection('users/$uid/taxs')
        .doc(tax.id)
        .update(tax.toDocument());
    final index = _taxs.indexWhere((p) => p.id == tax.id);
    if (index != -1) {
      _taxs[index] = tax;
      notifyListeners();
    }
  }

  Future<void> deletetax(String uid, String id) async {
    await _firestore.collection('users/$uid/taxs').doc(id).delete();
    _taxs.removeWhere((tax) => tax.id == id);
    notifyListeners();
  }
}
