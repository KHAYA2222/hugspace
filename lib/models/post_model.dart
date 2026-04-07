// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum Feeling {
  overwhelmed,
  lost,
  heartbroken,
  anxious,
  lonely,
  exhausted,
  hopeful,
  quietlySad,
  grateful,
  confused,
}

extension FeelingExtension on Feeling {
  String get label {
    switch (this) {
      case Feeling.overwhelmed: return 'overwhelmed';
      case Feeling.lost: return 'lost';
      case Feeling.heartbroken: return 'heartbroken';
      case Feeling.anxious: return 'anxious';
      case Feeling.lonely: return 'lonely';
      case Feeling.exhausted: return 'exhausted';
      case Feeling.hopeful: return 'hopeful';
      case Feeling.quietlySad: return 'quietly sad';
      case Feeling.grateful: return 'grateful';
      case Feeling.confused: return 'confused';
    }
  }

  String get emoji {
    switch (this) {
      case Feeling.overwhelmed: return '🌊';
      case Feeling.lost: return '🌫️';
      case Feeling.heartbroken: return '💔';
      case Feeling.anxious: return '🌀';
      case Feeling.lonely: return '🌙';
      case Feeling.exhausted: return '🍂';
      case Feeling.hopeful: return '🌱';
      case Feeling.quietlySad: return '🫧';
      case Feeling.grateful: return '🌸';
      case Feeling.confused: return '🌙';
    }
  }

  static Feeling fromString(String value) {
    return Feeling.values.firstWhere(
      (f) => f.label == value,
      orElse: () => Feeling.lost,
    );
  }
}

class PostModel {
  final String id;
  final String content;
  final Feeling feeling;
  final String authorName; // random cute name
  final int hugCount;
  final bool needsThat; // "I needed that" acknowledged
  final DateTime createdAt;
  final DateTime expiresAt;

  PostModel({
    required this.id,
    required this.content,
    required this.feeling,
    required this.authorName,
    this.hugCount = 0,
    this.needsThat = false,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'feeling': feeling.label,
      'authorName': authorName,
      'hugCount': hugCount,
      'needsThat': needsThat,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      content: data['content'] ?? '',
      feeling: FeelingExtension.fromString(data['feeling'] ?? 'lost'),
      authorName: data['authorName'] ?? 'Anonymous Soul',
      hugCount: data['hugCount'] ?? 0,
      needsThat: data['needsThat'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }
}
