import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/widgets/photo_picker.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/booking.dart';

/// "Write review" sheet for completed stays, feeding the platform's trust
/// and review system.
Future<void> showReviewSheet(BuildContext context, Booking booking) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _ReviewSheet(booking: booking),
    ),
  );
}

class _ReviewSheet extends StatefulWidget {
  final Booking booking;

  const _ReviewSheet({required this.booking});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

/// Stateful only for the TextEditingController; the star rating lives in
/// an [IndexCubit].
class _ReviewSheetState extends State<_ReviewSheet> {
  final _controller = TextEditingController();

  /// Photos attached to the review, still on the device — matching the
  /// "Update Photo" gallery step in the prototype.
  final _photos = <String>[];
  bool _picking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    setState(() => _picking = true);
    try {
      final picked = await sl<PhotoService>().pick(limit: 3 - _photos.length);
      if (!mounted) return;
      setState(() => _photos.addAll(picked));
    } on ServerException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => IndexCubit(5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'Write review',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'How was your stay at ${widget.booking.propertyName}?',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: BlocBuilder<IndexCubit, int>(
                  builder: (context, rating) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () => context.read<IndexCubit>().set(i),
                          icon: Icon(
                            i <= rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.star,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Photo or Video',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              PhotoPickerField(
                photos: _photos,
                busy: _picking,
                max: 3,
                onAdd: _addPhotos,
                onRemove: (path) => setState(() => _photos.remove(path)),
              ),
              const SizedBox(height: 16),
              Text(
                'Write your review',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Share what future housemates should know...',
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Submit review',
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Thanks! Your review helps keep Houseslice trustworthy.',
                        ),
                      ),
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
