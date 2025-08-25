import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/library_model.dart';

class LibraryProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<LibraryModel> _librarys = [];
  List<LibraryModel> get librarys => _librarys;
  String? currentLibraryId;
  String? get getCurrentLibraryIdValue => currentLibraryId;

  Future<String?> getCurrentLibraryId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('currentLibraryId');
    currentLibraryId = id;
    return id;
  }

  Future<void> loadlibraries(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final snapshot = await _firestore.collection('libraries').get();
    List<dynamic> userLibraryIds = userDoc.data()?['libraries'] ?? [];
    _librarys =
        snapshot.docs
            .where((doc) => userLibraryIds.contains(doc.id))
            .map((doc) => LibraryModel.fromDocument(doc))
            .toList();
    notifyListeners();
  }

  LibraryModel getlibrary(String uid, String id) {
    return _librarys.firstWhere((library) => library.id == id);
  }

  Future<void> addlibrary(String uid, LibraryModel library) async {
    final ref = await _firestore
        .collection('libraries')
        .add(library.toDocument());
    library.id = ref.id;
    _librarys.add(library);
    await _firestore.collection('users').doc(uid).set({
      'libraries': FieldValue.arrayUnion([library.id]),
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> updatelibrary(String uid, LibraryModel library) async {
    await _firestore
        .collection('libraries')
        .doc(library.id)
        .update(library.toDocument());
    final index = _librarys.indexWhere((p) => p.id == library.id);
    if (index != -1) {
      _librarys[index] = library;
      notifyListeners();
    }
  }

  Future<void> deletelibrary(String uid, String id) async {
    await _firestore.collection('users').doc(uid).update({
      'libraries': FieldValue.arrayRemove([id]),
    });
    await _firestore.collection('libraries').doc(id).delete();
    _librarys.removeWhere((library) => library.id == id);
    notifyListeners();
  }

  void clear() {
    _librarys = [];
    notifyListeners();
  }
}
