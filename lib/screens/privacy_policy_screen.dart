// lib/screens/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: AppColors.creamWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.softCharcoal, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.softCharcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤍', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    const Text(
                      'Your privacy matters to us.',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepRose,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'hugspace is built on anonymity and trust. '
                      'Here\'s exactly what we collect and why.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.warmGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              ..._sections.asMap().entries.map((entry) {
                final i = entry.key;
                final section = entry.value;
                return _PolicySection(
                  section: section,
                  delay: 100 + (i * 80),
                );
              }),

              const SizedBox(height: 24),

              // Last updated
              Center(
                child: Text(
                  'Last updated: June 2026',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.mutedTaupe,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Policy section widget ──────────────────────────────────────────────────
class _PolicySection extends StatelessWidget {
  final _Section section;
  final int delay;

  const _PolicySection({required this.section, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(section.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.softCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.warmGray,
              height: 1.65,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.08, end: 0, delay: delay.ms);
  }
}

// ── Policy content ─────────────────────────────────────────────────────────
class _Section {
  final String emoji;
  final String title;
  final String body;
  const _Section(this.emoji, this.title, this.body);
}

const List<_Section> _sections = [
  _Section(
    '👤',
    'Anonymous Identity',
    'hugspace never asks for your name, email, or any personal information. '
        'When you open the app, you are assigned a randomly generated name '
        '(like "Gentle Sparrow") that exists only on your device. '
        'You cannot be identified from this name.',
  ),
  _Section(
    '📝',
    'Posts & Content',
    'When you share a post, the content, your generated name, and a feeling '
        'tag are stored in our database. Posts are automatically deleted after '
        '48 hours. We do not link posts to any real-world identity.',
  ),
  _Section(
    '🔑',
    'Anonymous Authentication',
    'We use Firebase Anonymous Authentication to secure your session. '
        'This creates a temporary, random user ID that is never linked to '
        'any personal information. It is used only to prevent abuse and '
        'enforce fair usage of the app.',
  ),
  _Section(
    '🤗',
    'Hugs & Interactions',
    'When you send a hug or acknowledge a post, only the action is recorded '
        '(a counter increment). We store which posts you have hugged locally '
        'on your device so you cannot hug the same post twice. This data '
        'never leaves your device.',
  ),
  _Section(
    '📊',
    'Analytics & Crash Reporting',
    'We may collect anonymised crash reports and usage analytics via Firebase '
        'to improve app stability. This data contains no personally identifiable '
        'information and cannot be traced back to you.',
  ),
  _Section(
    '🔒',
    'Data Security',
    'All data is stored securely using Google Firebase, which is protected '
        'by industry-standard encryption in transit and at rest. '
        'Access to the database is restricted by security rules that '
        'prevent any unauthorised reads or writes.',
  ),
  _Section(
    '🧒',
    'Children\'s Privacy',
    'hugspace is not directed at children under the age of 13. '
        'We do not knowingly collect any information from children. '
        'If you believe a child has submitted content, please contact us '
        'so we can remove it promptly.',
  ),
  _Section(
    '✏️',
    'Changes to This Policy',
    'We may update this Privacy Policy from time to time. '
        'Any changes will be reflected in the "Last updated" date above. '
        'Continued use of the app after changes constitutes acceptance '
        'of the updated policy.',
  ),
  _Section(
    '📬',
    'Contact Us',
    'If you have any questions or concerns about this Privacy Policy, '
        'please contact us at: privacy@hugspace.app\n\n'
        'We will do our best to respond within 5 business days.',
  ),
];
