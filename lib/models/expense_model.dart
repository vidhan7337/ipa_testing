import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String? id;
  String? name;
  double? amount;
  DateTime? date;
  String? description;

  ExpenseModel({this.id, this.name, this.amount, this.date, this.description});

  factory ExpenseModel.fromDocument(DocumentSnapshot doc) {
    return ExpenseModel(
      id: doc.id,
      name: doc['name'],
      amount: doc['amount'] as double,
      description: doc['description'],
      date: (doc['date'] as Timestamp).toDate(),
    );
  }
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }
}
