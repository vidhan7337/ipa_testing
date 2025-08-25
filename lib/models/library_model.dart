import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryModel {
  String? id;
  String? name;
  String? address;
  String? phone;
  String? email;
  String? logoUrl;

  LibraryModel({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
  });

  factory LibraryModel.fromDocument(DocumentSnapshot doc) {
    return LibraryModel(
      id: doc.id,
      name: doc['name'],
      address: doc['address'],
      phone: doc['phone'],
      email: doc['email'],
      logoUrl: doc['logoUrl'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
    };
  }
}
