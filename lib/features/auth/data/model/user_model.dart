import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime? dob;
  final bool isMarried;
  final DateTime? anniversary;
  final String? weeklyOff;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.dob,
    this.isMarried = false,
    this.anniversary,
    this.weeklyOff,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      isMarried: map['isMarried'] ?? false,
      anniversary: map['anniversary'] != null ? (map['anniversary'] as Timestamp).toDate() : null,
      weeklyOff: map['weeklyOff'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'isMarried': isMarried,
      'anniversary': anniversary != null ? Timestamp.fromDate(anniversary!) : null,
      'weeklyOff': weeklyOff,
    };
  }
}
