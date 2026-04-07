// lib/services/session_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionService {
  static const String _sessionIdKey = 'session_id';
  static const String _sessionNameKey = 'session_name';
  static const String _huggedPostsKey = 'hugged_posts';

  static final List<String> _adjectives = [
    'Quiet', 'Gentle', 'Soft', 'Tender', 'Calm', 'Warm',
    'Misty', 'Drifting', 'Still', 'Dreamy', 'Wandering',
    'Velvet', 'Silver', 'Golden', 'Moonlit', 'Whispering',
    'Floating', 'Sleepy', 'Hopeful', 'Wistful', 'Serene',
  ];

  static final List<String> _nouns = [
    'Sparrow', 'Willow', 'Cloud', 'Feather', 'Petal',
    'Ember', 'Brook', 'Birch', 'Fern', 'Meadow',
    'Lantern', 'Tide', 'Leaf', 'Moon', 'Star',
    'Garden', 'River', 'Candle', 'Breeze', 'Rain',
  ];

  static String _generateName() {
    final adj = _adjectives[DateTime.now().millisecondsSinceEpoch % _adjectives.length];
    final noun = _nouns[(DateTime.now().millisecondsSinceEpoch ~/ 100) % _nouns.length];
    return '$adj $noun';
  }

  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_sessionIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_sessionIdKey, id);
    }
    return id;
  }

  static Future<String> getSessionName() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString(_sessionNameKey);
    if (name == null) {
      name = _generateName();
      await prefs.setString(_sessionNameKey, name);
    }
    return name;
  }

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
