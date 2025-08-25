import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

class InvoiceProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  List<InvoiceModel> get filteredInvoices => _filteredInvoices;
  List<InvoiceModel> get invoices => _invoices;

  List<InvoiceModel> inovicesByMemberId(String memberId) {
    return _invoices.where((invoice) => invoice.memberId == memberId).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));
  }

  // List<String> get followUpMembers {
  //   final now = DateTime.now();
  //   return _invoices
  //       .where((member) {
  //         if (member.endDate != null) {
  //           final difference = member.endDate!.difference(now).inDays;
  //           return difference >= 0 && difference <= 5;
  //         }
  //         return false;
  //       })
  //       .map((e) => e.memberId!)
  //       .toSet()
  //       .toList();
  // }

  // int get followUpMembersCount {
  //   final now = DateTime.now();
  //   return _invoices
  //       .where((member) {
  //         if (member.endDate != null) {
  //           final difference = member.endDate!.difference(now).inDays;
  //           return difference >= 0 && difference <= 5;
  //         }
  //         return false;
  //       })
  //       .map((e) => e.memberId!)
  //       .toSet()
  //       .length;
  // }

  // int get followUpSeatsCount {
  //   final now = DateTime.now();
  //   return _invoices
  //       .where((member) {
  //         if (member.endDate != null) {
  //           final difference = member.endDate!.difference(now).inDays;
  //           return difference >= 0 && difference <= 5;
  //         }
  //         return false;
  //       })
  //       .map((e) => e.seatId!)
  //       .toSet()
  //       .length;
  // }

  // List<String> get followUpSeats {
  //   final now = DateTime.now();
  //   return _invoices
  //       .where((member) {
  //         if (member.endDate != null) {
  //           final difference = member.endDate!.difference(now).inDays;
  //           return difference >= 0 && difference <= 5;
  //         }
  //         return false;
  //       })
  //       .map((e) => e.seatId!)
  //       .toSet()
  //       .toList();
  // }

  List<InvoiceModel> searchInvoices({String? query}) {
    return _filteredInvoices =
        _invoices.where((invoice) {
          final queryLower = query?.toLowerCase() ?? '';
          return invoice.id?.toLowerCase().contains(queryLower) == true ||
              invoice.memberId?.toLowerCase().contains(queryLower) == true ||
              invoice.memberName?.toLowerCase().contains(queryLower) == true ||
              invoice.startDate?.toString().toLowerCase().contains(
                    queryLower,
                  ) ==
                  true ||
              invoice.memberPhone?.toString().toLowerCase().contains(
                    queryLower,
                  ) ==
                  true ||
              invoice.seatId?.toLowerCase().contains(queryLower) == true ||
              invoice.date?.toString().toLowerCase().contains(queryLower) ==
                  true ||
              invoice.endDate?.toString().toLowerCase().contains(queryLower) ==
                  true;
        }).toList();
  }

  Future<void> loadinvoices(String libraryId) async {
    final snapshot =
        await _firestore.collection('libraries/$libraryId/invoices').get();
    _invoices =
        snapshot.docs.map((doc) => InvoiceModel.fromDocument(doc)).toList();
    notifyListeners();
  }

  Future<String> addinvoice(String libraryId, InvoiceModel invoice) async {
    final snapshot =
        await _firestore.collection('libraries/$libraryId/invoices').get();

    final librarySnapshot =
        await _firestore.collection('libraries').doc(libraryId).get();
    final libraryName = librarySnapshot.data()!['name'] as String;
    final invoiceNumber = snapshot.docs.length + 1;
    final documentId = '$libraryName-inv-$invoiceNumber';

    await _firestore
        .collection('libraries/$libraryId/invoices')
        .doc(documentId)
        .set(invoice.toDocument());

    invoice.id = documentId;
    _invoices.add(invoice);
    notifyListeners();
    return documentId;
  }

  Future<void> updateinvoice(String libraryId, InvoiceModel invoice) async {
    await _firestore
        .collection('libraries/$libraryId/invoices')
        .doc(invoice.id)
        .update(invoice.toDocument());
    final index = _invoices.indexWhere((p) => p.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }

  Future<void> deleteinvoice(String libraryId, String id) async {
    await _firestore
        .collection('libraries/$libraryId/invoices')
        .doc(id)
        .delete();
    _invoices.removeWhere((invoice) => invoice.id == id);
    notifyListeners();
  }

  void clear() {
    _invoices = [];
    notifyListeners();
  }
}
