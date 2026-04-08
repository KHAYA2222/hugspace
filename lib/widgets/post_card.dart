// lib/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'hug_animation.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String sessionId;
  final bool isOwnPost;
  final int index;

  const PostCard({
    super.key,
    required this.post,
    required this.sessionId,
    required this.isOwnPost,
    required this.index,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hasHugged = false;
  bool _showHugRain = false;

  @override
  void initState() {
    super.initState();
    _checkHugStatus();
  }

  Future<void> _checkHugStatus() async {
    final hugged = await SessionService.hasHugged(widget.post.id);
    if (mounted) setState(() => _hasHugged = hugged);
  }

  Future<void> _sendHug() async {
    if (_hasHugged || widget.isOwnPost) return;

    setState(() {
      _hasHugged = true;
      _showHugRain = true;
    });

    await SessionService.addHuggedPost(widget.post.id);
    await FirestoreService.sendHug(widget.post.id);
  }

  Color get _feelingColor {
    switch (widget.post.feeling) {
      case Feeling.overwhelmed:
        return const Color(0xFFB0C4DE);
      case Feeling.heartbroken:
        return const Color(0xFFFFB3C6);
      case Feeling.anxious:
        return const Color(0xFFDEB0E0);
      case Feeling.lonely:
        return const Color(0xFFB0D4DE);
      case Feeling.exhausted:
        return const Color(0xFFDEB0B0);
      case Feeling.hopeful:
        return const Color(0xFFB0DEB8);
      case Feeling.grateful:
        return const Color(0xFFDED8B0);
      default:
        return AppColors.roseMist;
    }
  }

  // Time remaining display
  String get _timeRemaining {
    final remaining = widget.post.expiresAt.difference(DateTime.now());
    if (remaining.inHours > 1) return '${remaining.inHours}h left';
    if (remaining.inMinutes > 1) return '${remaining.inMinutes}m left';
    return 'fading soon';
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          duration: 400.ms,
          delay: (widget.index * 80).ms,
        ),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 400.ms,
          delay: (widget.index * 80).ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.roseMist.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with feeling tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _feelingColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Author name
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _feelingColor.withOpacity(0.5),
                            ),
                            child: Center(
                              child: Text(
                                widget.post.feeling.emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.authorName,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.softCharcoal,
                                ),
                              ),
                              Text(
                                'feeling ${widget.post.feeling.label}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: AppColors.warmGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeago.format(widget.post.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: AppColors.mutedTaupe,
                            ),
                          ),
                          Text(
                            _timeRemaining,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              color: AppColors.softRose,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      height: 1.7,
                      color: AppColors.softCharcoal,
                    ),
                  ),
                ),

                // Hug section
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.blush.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Center(
                    child: HugButton(
                      hugCount: widget.post.hugCount,
                      hasHugged: _hasHugged,
                      isOwnPost: widget.isOwnPost,
                      onHug: _sendHug,
                      acknowledged: widget.post.needsThat,
                      onAcknowledge: widget.isOwnPost
                          ? () =>
                              FirestoreService.acknowledgeHugs(widget.post.id)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hug rain overlay
          if (_showHugRain)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: HugRainOverlay(
                  isActive: _showHugRain,
                  onComplete: () {
                    if (mounted) setState(() => _showHugRain = false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
