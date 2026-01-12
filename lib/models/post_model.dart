import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String leaderId;
  final Timestamp createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.leaderId,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      leaderId: map['leaderId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'leaderId': leaderId,
      'createdAt': createdAt,
    };
  }
}