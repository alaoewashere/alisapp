import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/report_model.dart';
import '../data/listings_repository.dart';

class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  String? _selected;
  final _otherController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final reason = _selected == ReportReasons.other
        ? _otherController.text.trim()
        : _selected;

    if (reason == null || reason.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر سبباً أو اكتب تفاصيل البلاغ')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(listingsRepositoryProvider).reportListing(
            ReportModel(
              listingId: widget.listingId,
              reporterId: userId,
              reason: reason,
            ),
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال البلاغ. شكراً لمساعدتك.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر إرسال البلاغ')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الإبلاغ عن الإعلان',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...ReportReasons.options.map(
                (reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                ),
              ),
              if (_selected == ReportReasons.other) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _otherController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'تفاصيل البلاغ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إرسال البلاغ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
