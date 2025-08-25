import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lib_app/models/plan_model.dart';

class InvoiceModel {
  String? id;
  String? memberId;
  String? libraryId;
  DateTime? date;
  DateTime? startDate;
  DateTime? endDate;
  PlanModel? plan;
  // TaxModel? tax;
  double? total;
  double? amountPaid;
  double? amountDue;
  String? paymentMethod;
  String? memberName;
  String? memberPhone;
  String? inpviceUrl;
  String? seatId;

  InvoiceModel({
    this.id,
    this.memberId,
    this.libraryId,
    this.date,
    this.startDate,
    this.endDate,
    this.plan,
    // this.tax,
    this.total,
    this.amountPaid,
    this.amountDue,
    this.paymentMethod,
    this.memberName,
    this.memberPhone,
    this.inpviceUrl,
    this.seatId,
  });

  factory InvoiceModel.fromDocument(DocumentSnapshot doc) {
    return InvoiceModel(
      id: doc.id,
      memberId: doc['memberId'],
      libraryId: doc['libraryId'],
      date: (doc['date'] as Timestamp).toDate(),
      startDate: (doc['startDate'] as Timestamp).toDate(),
      endDate: (doc['endDate'] as Timestamp).toDate(),
      plan: PlanModel.fromMap(doc['plan']),
      // tax: TaxModel.fromDocument(doc['tax']),
      total: doc['total'] as double?,
      amountPaid: doc['amountPaid'] as double?,
      amountDue: doc['amountDue'] as double?,
      paymentMethod: doc['paymentMethod'],
      memberName: doc['memberName'],
      memberPhone: doc['memberPhone'],
      inpviceUrl: doc['inpviceUrl'],
      seatId: doc['seatId'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'memberId': memberId,
      'libraryId': libraryId,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'plan': plan?.toDocument(),
      // 'tax': tax?.toDocument(),
      'total': total,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'paymentMethod': paymentMethod,
      'memberName': memberName,
      'memberPhone': memberPhone,
      'inpviceUrl': inpviceUrl,
      'seatId': seatId,
    };
  }
}
