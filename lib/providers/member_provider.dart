import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class MemberProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<MemberModel> _members = [];
  List<MemberModel> _filtermembers = [];
  List<MemberModel> get members => _members;
  List<MemberModel> get filteredMembers => _filtermembers;

  int get membersCount => _members.length;
  int get activeMembersCount =>
      _members.where((member) => member.isActive == true).length;
  int get inactiveMembersCount =>
      _members.where((member) => member.isActive == false).length;

  MemberModel getMemberById(String id) {
    return _members.firstWhere((member) => member.id == id);
  }

  List<MemberModel> filterMembers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    return _filtermembers =
        _members.where((member) {
          final idMatch =
              member.id?.toLowerCase().contains(lowerCaseQuery) ?? false;
          final nameMatch =
              member.name?.toLowerCase().contains(lowerCaseQuery) ?? false;
          return idMatch || nameMatch;
        }).toList();
  }

  double get totalpayment {
    double total = 0;
    for (var member in _members) {
      total += member.totalAmount ?? 0;
    }
    return total;
  }

  double get totalPaidAmt {
    double total = 0;
    for (var member in _members) {
      total += member.amountPaid ?? 0;
    }
    return total;
  }

  double get totalDueAmt {
    double total = 0;
    for (var member in _members) {
      total += member.amountDue ?? 0;
    }
    return total;
  }

  List<MemberModel> get membersWithPlanEndingSoon {
    final now = DateTime.now();
    return _members.where((member) {
      if (member.planEndDate != null) {
        final difference = member.planEndDate!.difference(now).inDays;
        return difference <= 1;
      }
      return false;
    }).toList();
  }

  int get membersWithDueAmount {
    return _members
        .where((member) => member.amountDue != null && member.amountDue! > 0)
        .length;
  }

  List<MemberModel> get membersWithDueAmountList {
    return _members
        .where((member) => member.amountDue != null && member.amountDue! > 0)
        .toList();
  }

  int get membersWithPlanEndingSoonCount {
    final now = DateTime.now();
    return _members.where((member) {
      if (member.planEndDate != null) {
        final difference = member.planEndDate!.difference(now).inDays;
        return difference <= 1;
      }
      return false;
    }).length;
  }

  bool isMemberIdAvailable(String id) {
    return _members.any((member) => member.id == id);
  }

  Future<String> getlastMemberId() async {
    if (_members.isEmpty) {
      return '1';
    } else {
      final lastMember = _members.last;
      final lastId = int.tryParse(lastMember.id!);
      if (lastId != null) {
        return (lastId + 1).toString();
      } else {
        return '1';
      }
    }
  }

  Future<void> loadmembers(String libraryId) async {
    final snapshot =
        await _firestore.collection('libraries/$libraryId/members').get();
    _members =
        snapshot.docs.map((doc) => MemberModel.fromDocument(doc)).toList()
          ..sort((a, b) => int.parse(a.id!).compareTo(int.parse(b.id!)));

    notifyListeners();
  }

  Future<void> addmember(MemberModel member, String libraryId) async {
    final ref = await _firestore
        .collection('libraries/$libraryId/members')
        .doc(member.id.toString());
    await ref.set(member.toDocument());
    member.id = ref.id;
    _members.add(member);
    notifyListeners();
  }

  Future<void> updatemember(MemberModel member, String libraryId) async {
    await _firestore
        .collection('libraries/$libraryId/members')
        .doc(member.id)
        .update(member.toDocument());
    final index = _members.indexWhere((p) => p.id == member.id);
    if (index != -1) {
      _members[index] = member;
      notifyListeners();
    }
  }

  Future<void> deletemember(String id, String libraryId) async {
    await _firestore
        .collection('libraries/$libraryId/members')
        .doc(id)
        .delete();
    _members.removeWhere((member) => member.id == id);
    notifyListeners();
  }

  void clear() {
    _members = [];
    notifyListeners();
  }
}
