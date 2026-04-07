// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'feed_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _generatedName = '';
  bool _nameReady = false;
  bool _isFirstVisit = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Check if new session
    final prefs = await SessionService.getSessionId();
    final name = await SessionService.getSessionName();

    if (mounted) {
      setState(() {
        _generatedName = name;
        _nameReady = true;
      });
    }

    // Brief splash then proceed
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) _goToFeed();
  }

  void _goToFeed() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const FeedScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blush,
              AppColors.roseMist.withOpacity(0.5),
              AppColors.creamWhite,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated heart/hug emoji
              Text('🫂', style: const TextStyle(fontSize: 72))
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 800.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              Text(
                'hugspace',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepRose,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms),

              const SizedBox(height: 8),

              Text(
                'a warm space to be heard',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: AppColors.warmGray,
                  letterSpacing: 0.2,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 48),

              if (_nameReady) ...[
                Text(
                  'you arrived as',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    color: AppColors.mutedTaupe,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.roseMist.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    '🌸 $_generatedName',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepRose,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 1200.ms)
                    .scale(begin: const Offset(0.9, 0.9), delay: 1200.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 12),

                Text(
                  'no names, no judgment, just warmth',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.mutedTaupe,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1600.ms),
              ],

              const SizedBox(height: 60),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softRose,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.2, 1.2),
                        duration: 600.ms,
                        delay: (i * 200).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(0.6, 0.6),
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      );
                }),
              ).animate().fadeIn(duration: 400.ms, delay: 1800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
