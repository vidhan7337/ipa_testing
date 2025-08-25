import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan_model.dart';

class PlanProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<PlanModel> _plans = [];
  List<PlanModel> get plans => _plans;

  List<PlanModel> get reservedSeatPlans =>
      _plans.where((plan) => plan.isReserved!).toList();

  List<PlanModel> get unreservedSeatPlans =>
      _plans.where((plan) => !plan.isReserved!).toList();

  Future<void> loadPlans(String lid) async {
    final snapshot = await _firestore.collection('libraries/$lid/plans').get();
    _plans = snapshot.docs.map((doc) => PlanModel.fromDocument(doc)).toList();
    notifyListeners();
  }

  Future<void> addPlan(String lid, PlanModel plan) async {
    final ref = await _firestore
        .collection('libraries/$lid/plans')
        .add(plan.toDocument());
    plan.id = ref.id;
    _plans.add(plan);
    notifyListeners();
  }

  Future<void> updatePlan(String lid, PlanModel plan) async {
    await _firestore
        .collection('libraries/$lid/plans')
        .doc(plan.id)
        .update(plan.toDocument());
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String lid, String id) async {
    await _firestore.collection('libraries/$lid/plans').doc(id).delete();
    _plans.removeWhere((plan) => plan.id == id);
    notifyListeners();
  }

  void clear() {
    _plans = [];
    notifyListeners();
  }
}
