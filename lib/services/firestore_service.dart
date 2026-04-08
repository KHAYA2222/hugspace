// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _postsCollection = 'posts';

  // ── Stream of live posts ──────────────────────────────────────────────────
  static Stream<List<PostModel>> postsStream() {
    return _db
        .collection(_postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .map(PostModel.fromFirestore)
          .where((p) => p.expiresAt.isAfter(now))
          .toList();
    });
  }

  // ── Create a new post ─────────────────────────────────────────────────────
  static Future<String> createPost({
    required String content,
    required Feeling feeling,
    required String authorName,
  }) async {
    final now = DateTime.now();
    final post = PostModel(
      id: '',
      content: content,
      feeling: feeling,
      authorName: authorName,
      hugCount: 0,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 48)),
    );

    final ref = await _db.collection(_postsCollection).add(post.toFirestore());

    return ref.id;
  }

  // ── Send a hug (increment counter) ───────────────────────────────────────
  static Future<void> sendHug(String postId) async {
    await _db.collection(_postsCollection).doc(postId).update({
      'hugCount': FieldValue.increment(1),
    });
  }

  // ── "I needed that" acknowledgement ──────────────────────────────────────
  static Future<void> acknowledgeHugs(String postId) async {
    await _db.collection(_postsCollection).doc(postId).update({
      'needsThat': true,
    });
  }

  // ── Delete expired posts (call periodically) ──────────────────────────────
  static Future<void> cleanExpiredPosts() async {
    final expired = await _db
        .collection(_postsCollection)
        .where('expiresAt', isLessThan: Timestamp.now())
        .get();

    final batch = _db.batch();
    for (final doc in expired.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
