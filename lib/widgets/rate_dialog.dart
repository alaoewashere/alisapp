import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';
import '../widgets/user_avatar.dart';

const _starGold = Color(0xFFF5A623);

/// Bottom sheet for rating another user after a completed deal.
Future<bool?> showRateDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String listingId,
  required String reviewedId,
  required String reviewedName,
  String? reviewedAvatarSeed,
  required String subtitle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => RateDialog(
      listingId: listingId,
      reviewedId: reviewedId,
      reviewedName: reviewedName,
      reviewedAvatarSeed: reviewedAvatarSeed,
      subtitle: subtitle,
    ),
  );
}

class RateDialog extends ConsumerStatefulWidget {
  const RateDialog({
    super.key,
    required this.listingId,
    required this.reviewedId,
    required this.reviewedName,
    this.reviewedAvatarSeed,
    required this.subtitle,
  });

  final String listingId;
  final String reviewedId;
  final String reviewedName;
  final String? reviewedAvatarSeed;
  final String subtitle;

  @override
  ConsumerState<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends ConsumerState<RateDialog> {
  int _selectedStars = 0;
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStars < 1 || _submitting) return;

    setState(() => _submitting = true);
    try {
      await ref.read(ratingServiceProvider).submitRating(
            listingId: widget.listingId,
            reviewedId: widget.reviewedId,
            stars: _selectedStars,
            reviewText: _controller.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on RatingException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إرسال التقييم، حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final charCount = _controller.text.length;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'كيف كانت تجربتك؟',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                UserAvatar(
                  avatarSeed: widget.reviewedAvatarSeed,
                  size: 56,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reviewedName,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    final filled = star <= _selectedStars;
                    return _AnimatedStar(
                      filled: filled,
                      onTap: () => setState(() => _selectedStars = star),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: _controller,
                    maxLength: 200,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقاً (اختياري)',
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.borderLight.withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$charCount/200',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedStars >= 1 && !_submitting ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'إرسال التقييم',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'تقييماتك تساعد المجتمع على الثقة بالبائعين',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  const _AnimatedStar({
    required this.filled,
    required this.onTap,
  });

  final bool filled;
  final VoidCallback onTap;

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedStar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filled && !oldWidget.filled) {
      _controller.forward(from: 0).then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 40,
            color: widget.filled
                ? _starGold
                : AppColors.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
