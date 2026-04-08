// lib/widgets/hug_animation.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Floating hug particle ─────────────────────────────────────────────────

class HugParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  Color color;
  String emoji;
  double rotation;
  double rotationSpeed;

  HugParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
    required this.emoji,
    required this.rotation,
    required this.rotationSpeed,
  });
}

// ── Hug Rain Overlay ──────────────────────────────────────────────────────

class HugRainOverlay extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onComplete;

  const HugRainOverlay({
    super.key,
    required this.isActive,
    this.onComplete,
  });

  @override
  State<HugRainOverlay> createState() => _HugRainOverlayState();
}

class _HugRainOverlayState extends State<HugRainOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<HugParticle> _particles = [];
  final Random _random = Random();
  final List<String> _emojis = ['🤗', '💕', '🌸', '💗', '✨', '🫂', '💞'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.isActive) _startRain();
  }

  @override
  void didUpdateWidget(HugRainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startRain();
    }
  }

  void _startRain() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(HugParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.5,
        size: 16 + _random.nextDouble() * 20,
        speed: 0.3 + _random.nextDouble() * 0.4,
        opacity: 0.7 + _random.nextDouble() * 0.3,
        color: AppColors.hugColors[_random.nextInt(AppColors.hugColors.length)],
        emoji: _emojis[_random.nextInt(_emojis.length)],
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      ));
    }
    _controller.forward(from: 0);
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) {
        p.y += p.speed * 0.015;
        p.rotation += p.rotationSpeed;
        if (p.y > 0.5) {
          p.opacity = (1 - (p.y - 0.5) * 4).clamp(0, 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive && _particles.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _HugRainPainter(particles: _particles),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HugRainPainter extends CustomPainter {
  final List<HugParticle> particles;
  _HugRainPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final tp = TextPainter(
        text: TextSpan(
          text: p.emoji,
          style: TextStyle(
              fontSize: p.size, color: Colors.white.withOpacity(p.opacity)),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HugRainPainter old) => true;
}

// ── Hug Button with ripple bloom ─────────────────────────────────────────

class HugButton extends StatefulWidget {
  final int hugCount;
  final bool hasHugged;
  final bool isOwnPost;
  final VoidCallback onHug;
  final VoidCallback? onAcknowledge;
  final bool acknowledged;

  const HugButton({
    super.key,
    required this.hugCount,
    required this.hasHugged,
    required this.isOwnPost,
    required this.onHug,
    this.onAcknowledge,
    this.acknowledged = false,
  });

  @override
  State<HugButton> createState() => _HugButtonState();
}

class _HugButtonState extends State<HugButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rippleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _rippleAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  void _onTap() {
    if (widget.hasHugged || widget.isOwnPost) return;
    _scaleController.forward(from: 0);
    _rippleController.forward(from: 0);
    widget.onHug();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hug button
        if (!widget.isOwnPost)
          GestureDetector(
            onTap: _onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple
                AnimatedBuilder(
                  animation: _rippleAnim,
                  builder: (_, __) => Container(
                    width: 60 + (_rippleAnim.value * 30),
                    height: 60 + (_rippleAnim.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.softRose.withOpacity(
                        (1 - _rippleAnim.value) * 0.3,
                      ),
                    ),
                  ),
                ),
                // Button
                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.hasHugged
                            ? [AppColors.deepRose, AppColors.softRose]
                            : [AppColors.roseMist, AppColors.blush],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softRose.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.hasHugged ? '🫂' : '🤗',
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 6),

        // Count
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.hugCount == 0
                ? 'be the first to hug'
                : '${widget.hugCount} hug${widget.hugCount == 1 ? '' : 's'}',
            key: ValueKey(widget.hugCount),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.mutedTaupe,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // "I needed that" — only on own posts
        if (widget.isOwnPost && widget.hugCount > 0) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: widget.acknowledged ? null : widget.onAcknowledge,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.acknowledged
                    ? AppColors.mintWhisper
                    : AppColors.blush,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.acknowledged
                      ? const Color(0xFF6BCBA0)
                      : AppColors.roseMist,
                ),
              ),
              child: Text(
                widget.acknowledged ? '🤍 I needed that' : 'I needed that 🤍',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.acknowledged
                      ? const Color(0xFF3D8A65)
                      : AppColors.deepRose,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
