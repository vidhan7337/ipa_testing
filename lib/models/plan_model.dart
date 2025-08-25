import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  String? id;
  String? name;
  int? price;
  int? duration;
  bool? isReserved;

  PlanModel({this.id, this.name, this.price, this.duration, this.isReserved});

  factory PlanModel.fromDocument(DocumentSnapshot doc) {
    return PlanModel(
      id: doc.id,
      name: doc['name'],
      price: doc['price'] as int?,
      duration: doc['duration'] as int?,
      isReserved: doc['isReserved'] as bool?,
    );
  }
  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration': duration,
      'isReserved': isReserved,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      id: map['id'],
      name: map['name'],
      price: map['price'] as int?,
      duration: map['duration'] as int?,
      isReserved: map['isReserved'] as bool?,
    );
  }
}
