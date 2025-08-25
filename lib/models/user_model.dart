import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;

  UserModel({this.id, this.name, this.email, this.phone});

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      name: doc['name'] as String?,
      email: doc['email'] as String?,
      phone: doc['phone'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String?,
      name: data['name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
    );
  }
}
