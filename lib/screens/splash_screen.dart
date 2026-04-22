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

  // FIX #1: Removed unused `_isFirstVisit` field that was always false
  // and never actually used anywhere.

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // FIX #2: `getSessionId()` result was fetched but never used.
    // Only fetch what you need — the session name.
    final name = await SessionService.getSessionName();

    if (mounted) {
      setState(() {
        _generatedName = name;
        _nameReady = true;
      });
    }

    // IMPROVEMENT: Extended splash to 3200ms so all animations
    // (including the name card at 1200ms delay) have time to fully
    // play before the screen transitions away.
    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) _goToFeed();
  }

  void _goToFeed() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const FeedScreen(),
        transitionsBuilder: (_, animation, __, child) {
          // IMPROVEMENT: Combined fade + subtle upward slide for a warmer
          // transition that matches the app's gentle aesthetic.
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // IMPROVEMENT: Use SafeArea so content isn't clipped on notched devices.
    return Scaffold(
      body: SafeArea(
        // SafeArea top/bottom padding but keep gradient full-bleed
        top: false,
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Hero emoji ────────────────────────────────────────────
              const Text('🫂', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    duration: 900.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // ── App name ──────────────────────────────────────────────
              const Text(
                'hugspace',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepRose,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, delay: 400.ms),

              const SizedBox(height: 10),

              // ── Tagline ───────────────────────────────────────────────
              const Text(
                'a warm space to be heard',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: AppColors.warmGray,
                  letterSpacing: 0.2,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 650.ms),

              const SizedBox(height: 52),

              // ── Name card — shown once data is ready ──────────────────
              // FIX #3: Wrapped in AnimatedSwitcher so the card fades in
              // smoothly instead of popping in abruptly. A fixed-height
              // placeholder avoids layout shift while loading.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOut,
                child: _nameReady
                    ? _NameCard(
                        name: _generatedName, key: const ValueKey('card'))
                    : const SizedBox(height: 88, key: ValueKey('placeholder')),
              ),

              const SizedBox(height: 56),

              // ── Breathing loading dots ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      color: AppColors.softRose,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.3, 1.3),
                        duration: 600.ms,
                        delay: (i * 200).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.3, 1.3),
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

// ── Extracted widget for the name card ────────────────────────────────────────
// IMPROVEMENT: Pulled into its own widget so animations are self-contained
// and the parent tree stays clean.
class _NameCard extends StatelessWidget {
  final String name;

  const _NameCard({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'you arrived as',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            color: AppColors.mutedTaupe,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.roseMist.withOpacity(0.55),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            '🌸  $name',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.deepRose,
            ),
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 350.ms).scale(
              begin: const Offset(0.88, 0.88),
              delay: 350.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 14),
        const Text(
          'no names, no judgment, just warmth',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: AppColors.mutedTaupe,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
      ],
    );
  }
}
