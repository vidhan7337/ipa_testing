import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seat_model.dart';

class SeatProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<SeatModel> _seats = [];
  List<SeatModel> get seats =>
      _seats..sort((a, b) {
        // Sort by series first, then by seat number
        int seriesComparison = (a.series ?? '').compareTo(b.series ?? '');
        if (seriesComparison != 0) return seriesComparison;
        return a.seatNumber!.compareTo(b.seatNumber!);
      });
  List<SeatModel> get availableSeats =>
      _seats.where((seat) => seat.isBooked == false).toList()..sort((a, b) {
        int seriesComparison = (a.series ?? '').compareTo(b.series ?? '');
        if (seriesComparison != 0) return seriesComparison;
        return a.seatNumber!.compareTo(b.seatNumber!);
      });
  List<SeatModel> get bookedSeats =>
      _seats.where((seat) => seat.isBooked == true).toList();
  List<SeatModel> get noticedSeats =>
      _seats.where((seat) => seat.isNoticed == true).toList();
  int get totalSeats => _seats.length;
  int get totalAvailableSeats => availableSeats.length;
  int get totalBookedSeats => bookedSeats.length;
  int get totalNoticedSeats => noticedSeats.length;

  // Helper methods for seat series
  List<String> get availableSeries {
    return _seats.map((seat) => seat.series ?? '').toSet().toList()..sort();
  }

  List<SeatModel> getSeatsBySeries(String series) {
    return _seats.where((seat) => seat.series == series).toList()
      ..sort((a, b) => a.seatNumber!.compareTo(b.seatNumber!));
  }

  int getTotalSeatsBySeries(String series) {
    return getSeatsBySeries(series).length;
  }

  int getAvailableSeatsBySeries(String series) {
    return getSeatsBySeries(
      series,
    ).where((seat) => seat.isBooked == false).length;
  }

  bool isSeatNumberAvailable(int seatNumber, String series) {
    return _seats.every(
      (seat) => !(seat.seatNumber == seatNumber && seat.series == series),
    );
  }

  int? getLastSeatNumber(String series) {
    final seatsInSeries =
        _seats.where((seat) => seat.series == series).toList();
    if (seatsInSeries.isEmpty) {
      return 0;
    }
    return seatsInSeries
        .map((seat) => seat.seatNumber)
        .reduce((a, b) => a! > b! ? a : b);
  }

  Future<void> loadseats(String libraryId) async {
    final snapshot =
        await _firestore.collection('libraries/$libraryId/seats').get();
    _seats = snapshot.docs.map((doc) => SeatModel.fromDocument(doc)).toList();
    for (var seat in _seats) {
      if (seat.expirationDate != null &&
          (seat.expirationDate!.difference(DateTime.now()).inDays <= 1)) {
        if (seat.isBooked == true && seat.isNoticed == false) {
          seat.isNoticed = true;
          await updateseat(libraryId, seat);
        }
      }
    }
    notifyListeners();
  }

  Future<void> addseat(String libraryId, int seatNo, String series) async {
    int? lastSeatNo = getLastSeatNumber(series);
    for (int i = 0; i < seatNo; i++) {
      lastSeatNo = lastSeatNo! + 1;
      SeatModel seat = SeatModel(
        seatNumber: lastSeatNo,
        series: series,
        isBooked: false,
        memberId: null,
        expirationDate: null,
        isNoticed: false,
      );
      final ref = _firestore
          .collection('libraries/$libraryId/seats')
          .doc('${series}_${seat.seatNumber}');
      await ref.set(seat.toDocument());
      seat.seatId = ref.id;
      _seats.add(seat);
    }
    notifyListeners();
  }

  Future<void> removeSeat(String libraryId, int seatNo, String series) async {
    int? lastSeatNo = getLastSeatNumber(series);
    for (int i = lastSeatNo!; i > lastSeatNo - seatNo; i--) {
      SeatModel? seat = _seats.firstWhere(
        (s) => s.seatNumber == i && s.series == series,
      );
      await _firestore
          .collection('libraries/$libraryId/seats')
          .doc(seat.seatId)
          .delete();
      _seats.remove(seat);
    }
    notifyListeners();
  }

  Future<void> updateseat(String libraryId, SeatModel seat) async {
    await _firestore
        .collection('libraries/$libraryId/seats')
        .doc(seat.seatId)
        .update(seat.toDocument());
    final index = _seats.indexWhere((p) => p.seatId == seat.seatId);
    if (index != -1) {
      _seats[index] = seat;
      notifyListeners();
    }
  }

  Future<void> deleteseat(String libraryId, String id) async {
    await _firestore.collection('libraries/$libraryId/seats').doc(id).delete();
    _seats.removeWhere((seat) => seat.seatId == id);
    notifyListeners();
  }

  void clear() {
    _seats = [];
    notifyListeners();
  }
}
