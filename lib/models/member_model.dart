import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lib_app/models/plan_model.dart';

class MemberModel {
  String? id;
  String? name;
  String? libraryId;
  String? seatId;
  String? email;
  String? phone;
  String? address;
  String? gender;
  DateTime? dateOfBirth;
  DateTime? dateOfJoining;
  bool? isActive;
  bool? isReserved; // Reserved Seat
  String? paymentStatus;
  double? amountPaid;
  double? amountDue;
  double? totalAmount;
  PlanModel? currentPlan;
  DateTime? planStartDate;
  DateTime? planEndDate;
  List<String>? invoices;

  MemberModel({
    this.id,
    this.name,
    this.libraryId,
    this.seatId,
    this.email,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.dateOfJoining,
    this.isActive,
    this.isReserved = true, // Default to Reserved Seat
    this.paymentStatus,
    this.amountPaid,
    this.amountDue,
    this.totalAmount,
    this.currentPlan,
    this.planStartDate,
    this.planEndDate,
    this.invoices,
  });

  factory MemberModel.fromDocument(DocumentSnapshot doc) {
    return MemberModel(
      id: doc.id,
      name: doc['name'],
      libraryId: doc['libraryId'],
      seatId: doc['seatId'],
      email: doc['email'],
      phone: doc['phone'],
      address: doc['address'],
      gender: doc['gender'],
      dateOfBirth: (doc['dateOfBirth'] as Timestamp?)?.toDate(),
      dateOfJoining: (doc['dateOfJoining'] as Timestamp?)?.toDate(),
      isActive: doc['isActive'] as bool?,
      isReserved:
          doc['isReserved'] as bool? ?? true, // Default to Reserved Seat
      paymentStatus: doc['paymentStatus'],
      amountPaid: (doc['amountPaid'] as num?)?.toDouble(),
      amountDue: (doc['amountDue'] as num?)?.toDouble(),
      totalAmount: (doc['totalAmount'] as num?)?.toDouble(),
      currentPlan:
          doc['currentPlan'] != null
              ? PlanModel.fromMap(doc['currentPlan'] as Map<String, dynamic>)
              : null,
      planStartDate: (doc['planStartDate'] as Timestamp?)?.toDate(),
      planEndDate: (doc['planEndDate'] as Timestamp?)?.toDate(),
      invoices:
          doc['invoices'] == null
              ? []
              : (doc['invoices'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList(),
      // invoices:
      //     doc['invoices'] == null
      //         ? ['']
      //         : (doc['invoices'] as List<String>?)
      //             ?.map((e) => e.toString())
      //             .toList(),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'libraryId': libraryId,
      'seatId': seatId,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'dateOfJoining':
          dateOfJoining != null ? Timestamp.fromDate(dateOfJoining!) : null,
      'isActive': isActive,
      'isReserved': isReserved ?? true, // Default to Reserved Seat
      'paymentStatus': paymentStatus,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'totalAmount': totalAmount,
      'currentPlan': currentPlan?.toDocument(),
      'planStartDate':
          planStartDate != null ? Timestamp.fromDate(planStartDate!) : null,
      'planEndDate':
          planEndDate != null ? Timestamp.fromDate(planEndDate!) : null,
      'invoices': invoices,
    };
  }
}
