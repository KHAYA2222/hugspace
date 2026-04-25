// lib/screens/share_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ShareSheet extends StatefulWidget {
  final String sessionName;

  const ShareSheet({super.key, required this.sessionName});

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Feeling? _selectedFeeling;
  bool _isPosting = false;
  int _charCount = 0;
  static const int _maxChars = 300;

  final List<Feeling> _feelings = Feeling.values;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);

      // FIX #1: Auto-scroll to bottom whenever text changes (user is typing),
      // ensuring the Post button stays visible above the keyboard.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (_controller.text.trim().isEmpty || _selectedFeeling == null) return;
    if (_charCount > _maxChars) return;

    setState(() => _isPosting = true);

    try {
      await FirestoreService.createPost(
        content: _controller.text.trim(),
        feeling: _selectedFeeling!,
        authorName: widget.sessionName,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw Exception('Upload timed out. Check your connection.'),
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong 🤍 Please try again',
              style: TextStyle(fontFamily: 'Nunito'),
            ),
            backgroundColor: AppColors.deepRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX #2: Use viewInsets.bottom from MediaQuery so the sheet padding
    // reacts to the software keyboard height correctly. This only works
    // reliably when showModalBottomSheet is called with
    // isScrollControlled: true  (see caller notes at the bottom of this file).
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        // FIX #3: Cap sheet at 90 % of screen height so it never grows
        // taller than the visible area even when the keyboard is up.
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar (fixed, never scrolls away) ──────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.roseMist,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // ── Scrollable body ─────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'What\'s on your heart?',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softCharcoal,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 4),

                    Text(
                      'Sharing as ${widget.sessionName} · vanishes in 48h',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.mutedTaupe,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Feeling chips
                    const Text(
                      'I\'m feeling...',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmGray,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _feelings.map((feeling) {
                        final isSelected = _selectedFeeling == feeling;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFeeling = feeling),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepRose
                                  : AppColors.blush,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.deepRose
                                    : AppColors.roseMist,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  feeling.emoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  feeling.label,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.warmGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                    const SizedBox(height: 20),

                    // Text field
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 5,
                          minLines: 3,
                          maxLength: _maxChars,
                          buildCounter: (_,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          // FIX #4: Increased delay to 500 ms so the keyboard
                          // is fully expanded before we scroll to the bottom.
                          // The addListener above handles the typing case, so
                          // this onTap only needs to handle the initial focus.
                          onTap: () {
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                            );
                          },
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            color: AppColors.softCharcoal,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Share what you\'re feeling, no judgment here...',
                            hintMaxLines: 2,
                            filled: true,
                            fillColor: AppColors.blush.withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.softRose,
                                width: 2,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 40),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 12),
                          child: Text(
                            '$_charCount/$_maxChars',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              color: _charCount > _maxChars
                                  ? AppColors.deepRose
                                  : AppColors.mutedTaupe,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                    const SizedBox(height: 20),

                    // Post button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: (_controller.text.trim().isNotEmpty &&
                                  _selectedFeeling != null &&
                                  !_isPosting)
                              ? _post
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepRose,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.roseMist,
                            disabledForegroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: _isPosting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Share with the world 🤍',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPORTANT — How to call this sheet from the parent widget:
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,   // ← REQUIRED: lets sheet resize with keyboard
//     useSafeArea: true,          // ← keeps content above home-indicator
//     backgroundColor: Colors.transparent,
//     builder: (_) => ShareSheet(sessionName: sessionName),
//   );
//
// Without isScrollControlled: true the viewInsets padding has no effect and
// the Post button will be hidden behind the keyboard.
// ─────────────────────────────────────────────────────────────────────────────
