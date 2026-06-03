// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import 'session_service.dart';

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
    // FIX: Guard against unauthenticated writes — Firestore rules now
    // require auth and a matching uid field, so we throw early with a
    // clear message instead of getting a cryptic permission-denied error.
    final uid = SessionService.currentUid;
    if (uid == null)
      throw Exception('Not authenticated. Please restart the app.');

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

    // FIX: Include uid in the Firestore document so the security rule
    // `request.resource.data.uid == request.auth.uid` passes.
    final data = post.toFirestore()..['uid'] = uid;

    final ref = await _db.collection(_postsCollection).add(data);
    return ref.id;
  }

  // ── Send a hug (increment counter) ───────────────────────────────────────
  static Future<void> sendHug(String postId) async {
    // FIX: Guard against unauthenticated hug attempts.
    final uid = SessionService.currentUid;
    if (uid == null) throw Exception('Not authenticated.');

    await _db.collection(_postsCollection).doc(postId).update({
      'hugCount': FieldValue.increment(1),
    });
  }

  // ── "I needed that" acknowledgement ──────────────────────────────────────
  static Future<void> acknowledgeHugs(String postId) async {
    // FIX: Guard against unauthenticated acknowledgements.
    final uid = SessionService.currentUid;
    if (uid == null) throw Exception('Not authenticated.');

    await _db.collection(_postsCollection).doc(postId).update({
      'needsThat': true,
    });
  }

  // ── Delete expired posts (call periodically) ──────────────────────────────
  // NOTE: This client-side cleanup is kept as a fallback but you should
  // also set up a Cloud Function scheduled trigger for reliable deletion.
  // See: https://firebase.google.com/docs/functions/schedule-functions
  static Future<void> cleanExpiredPosts() async {
    final uid = SessionService.currentUid;
    if (uid == null) throw Exception('Not authenticated.');

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
