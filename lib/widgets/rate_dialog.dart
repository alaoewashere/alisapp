import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../core/l10n/l10n_provider.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/widgets/auth_form_styles.dart';
import '../models/rating.dart';
import '../services/rating_service.dart';
import '../widgets/user_avatar.dart';

const _emptyStarColor = Color(0x30FFFFFF);

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
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedStars < 1 || _submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(ratingServiceProvider).submitRating(
            listingId: widget.listingId,
            reviewedId: widget.reviewedId,
            stars: _selectedStars,
            reviewText: _controller.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on RatingException catch (e) {
      // Show the reason inline — a snackbar is hidden behind this bottom sheet.
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = ref.read(appLocalizationsProvider).ratingSubmitFailed);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final charCount = _controller.text.length;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.canvas,
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
                    color: AppColors.pureWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  strings.rateExperienceTitle,
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.fieldCarbon,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: UserAvatar(
                    avatarSeed: widget.reviewedAvatarSeed,
                    size: 56,
                    darkStyle: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reviewedName,
                  style: AppFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: AppFonts.cairo(
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
                    cursorColor: AppColors.volt,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.pureWhite,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: AuthFormStyles.loginFieldDecoration(
                      hintText: strings.addCommentOptional,
                    ).copyWith(counterText: ''),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$charCount/200',
                    style: AppFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rejected.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.rejected.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.rejected,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AuthPrimaryButton(
                  label: strings.submitRating,
                  loading: _submitting,
                  loginStyle: true,
                  onPressed: _selectedStars >= 1 ? _submit : null,
                ),
                const SizedBox(height: 10),
                Text(
                  strings.ratingsHelpCommunity,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            widget.filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 32,
            color: widget.filled ? AppColors.volt : _emptyStarColor,
          ),
        ),
      ),
    );
  }
}
