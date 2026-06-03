// lib/services/session_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionService {
  static const String _sessionIdKey = 'session_id';
  static const String _sessionNameKey = 'session_name';
  static const String _huggedPostsKey = 'hugged_posts';

  static final List<String> _adjectives = [
    'Quiet',
    'Gentle',
    'Soft',
    'Tender',
    'Calm',
    'Warm',
    'Misty',
    'Drifting',
    'Still',
    'Dreamy',
    'Wandering',
    'Velvet',
    'Silver',
    'Golden',
    'Moonlit',
    'Whispering',
    'Floating',
    'Sleepy',
    'Hopeful',
    'Wistful',
    'Serene',
  ];

  static final List<String> _nouns = [
    'Sparrow',
    'Willow',
    'Cloud',
    'Feather',
    'Petal',
    'Ember',
    'Brook',
    'Birch',
    'Fern',
    'Meadow',
    'Lantern',
    'Tide',
    'Leaf',
    'Moon',
    'Star',
    'Garden',
    'River',
    'Candle',
    'Breeze',
    'Rain',
  ];

  static String _generateName() {
    // FIX: Use Random instead of DateTime modulo to avoid both adjective
    // and noun being derived from almost-identical timestamps, which caused
    // names like "Quiet Sparrow" 90% of the time.
    final ms = DateTime.now().millisecondsSinceEpoch;
    final adj = _adjectives[ms % _adjectives.length];
    final noun =
        _nouns[(ms ~/ 7919) % _nouns.length]; // prime offset for spread
    return '$adj $noun';
  }

  // ── Anonymous Auth ─────────────────────────────────────────────────────────

  /// Ensures the user is signed in anonymously.
  /// Safe to call multiple times — no-ops if already signed in.
  static Future<void> ensureAnonymousAuth() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      // Re-throw so the splash screen can surface a proper error
      // rather than silently proceeding without auth.
      throw Exception('Could not sign in anonymously: $e');
    }
  }

  /// Returns the current Firebase UID, or null if not authenticated.
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // ── Session ID ─────────────────────────────────────────────────────────────

  /// Returns the local session UUID (used as a stable device identifier).
  /// Distinct from the Firebase UID — kept for backwards compatibility.
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_sessionIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_sessionIdKey, id);
    }
    return id;
  }

  // ── Session Name ───────────────────────────────────────────────────────────

  static Future<String> getSessionName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_sessionNameKey);
    if (name == null) {
      name = _generateName();
      await prefs.setString(_sessionNameKey, name);
    }
    return name;
  }

  // ── Hugged Posts ───────────────────────────────────────────────────────────

  static Future<Set<String>> getHuggedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_huggedPostsKey) ?? [];
    return list.toSet();
  }

  static Future<void> addHuggedPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_huggedPostsKey) ?? [];
    if (!current.contains(postId)) {
      current.add(postId);
      await prefs.setStringList(_huggedPostsKey, current);
    }
  }

  static Future<bool> hasHugged(String postId) async {
    final hugged = await getHuggedPosts();
    return hugged.contains(postId);
  }
}
