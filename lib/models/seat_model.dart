import 'package:cloud_firestore/cloud_firestore.dart';

class SeatModel {
  String? seatId;
  int? seatNumber;
  String? series;
  bool? isBooked;
  String? memberId;
  DateTime? expirationDate;
  bool? isNoticed;

  SeatModel({
    this.seatId,
    this.seatNumber,
    this.series,
    this.isBooked,
    this.memberId,
    this.expirationDate,
    this.isNoticed,
  });

  factory SeatModel.fromDocument(DocumentSnapshot doc) {
    return SeatModel(
      seatId: doc.id,
      seatNumber: doc['seatNumber'] as int?,
      series: doc['series'] as String?,
      isBooked: doc['isBooked'] as bool?,
      memberId: doc['memberId'],
      expirationDate: (doc['expirationDate'] as Timestamp?)?.toDate(),
      isNoticed: doc['isNoticed'] as bool?,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'seatNumber': seatNumber,
      'series': series,
      'isBooked': isBooked,
      'memberId': memberId,
      'expirationDate':
          expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'isNoticed': isNoticed,
    };
  }

  // Helper method to get full seat identifier (e.g., "A1", "S15")
  String get fullSeatNumber {
    return '${series ?? ''}${seatNumber ?? ''}';
  }
}
