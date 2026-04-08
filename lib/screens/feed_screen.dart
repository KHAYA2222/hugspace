// lib/screens/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/post_card.dart';
import 'share_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  String _sessionId = '';
  String _sessionName = '';
  bool _sessionLoaded = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabAnim =
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);
    _loadSession();
  }

  Future<void> _loadSession() async {
    final id = await SessionService.getSessionId();
    final name = await SessionService.getSessionName();
    if (mounted) {
      setState(() {
        _sessionId = id;
        _sessionName = name;
        _sessionLoaded = true;
      });
      _fabController.forward();
    }
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(sessionName: _sessionName),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.blush,
                      AppColors.creamWhite,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'hugspace',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepRose,
                            letterSpacing: -0.5,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.1, end: 0),
                        const Spacer(),
                        if (_sessionLoaded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.roseMist.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🌸 $_sessionName',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepRose,
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'a warm space to be heard 🤍',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.warmGray,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                  ],
                ),
              ),
            ),
          ),

          // Feed
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: StreamBuilder<List<PostModel>>(
              stream: FirestoreService.postsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(child: _LoadingState());
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: _ErrorState(error: snapshot.error.toString()),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(onShare: _openShareSheet),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        sessionId: _sessionId,
                        isOwnPost: post.authorName == _sessionName,
                        index: index,
                      );
                    },
                    childCount: posts.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: _sessionLoaded
          ? ScaleTransition(
              scale: _fabAnim,
              child: GestureDetector(
                onTap: _openShareSheet,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.deepRose, AppColors.warmCoral],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepRose.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🫂', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Loading state ─────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 40))
              .animate(onPlay: (c) => c.repeat())
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms)
              .then()
              .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(0.8, 0.8),
                  duration: 1000.ms),
          const SizedBox(height: 16),
          const Text(
            'gathering warmth...',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                color: AppColors.mutedTaupe),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Something went quiet...',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                color: AppColors.softCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.deepRose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onShare;
  const _EmptyState({required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌙', style: TextStyle(fontSize: 56))
              .animate()
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 20),
          const Text(
            'It\'s quiet here',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.softCharcoal,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share what\'s\non your heart today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              color: AppColors.warmGray,
              height: 1.6,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.deepRose, AppColors.warmCoral]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepRose.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Share how you feel 🤍',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
