import 'package:cloud_firestore/cloud_firestore.dart';

class TaxModel {
  String? id;
  String? name;
  double? percentage;

  TaxModel({this.id, this.name, this.percentage});

  factory TaxModel.fromDocument(DocumentSnapshot doc) {
    return TaxModel(
      id: doc.id,
      name: doc['name'] as String?,
      percentage: (doc['percentage'] as num?)?.toDouble(),
    );
  }
  Map<String, dynamic> toDocument() {
    return {'name': name, 'percentage': percentage};
  }
}
