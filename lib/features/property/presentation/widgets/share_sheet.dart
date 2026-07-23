import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/property.dart';

/// "Share to" bottom sheet from the details screen. Copies a deep link to
/// the clipboard for each network (real share intents come later).
Future<void> showShareSheet(BuildContext context, Property property) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => _ShareSheet(property: property),
  );
}

class _ShareSheet extends StatelessWidget {
  final Property property;

  const _ShareSheet({required this.property});

  Future<void> _share(BuildContext context, String network) async {
    await Clipboard.setData(ClipboardData(
      text: 'Check out ${property.name} on Houseslice — '
          'houseslice.app/p/${property.id}',
    ));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Link copied — ready to paste in $network'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Facebook', const Color(0xFF1877F2), Icons.facebook),
      ('Instagram', const Color(0xFFE1306C), Icons.photo_camera_outlined),
      ('Twitter', const Color(0xFF1DA1F2), Icons.alternate_email),
      ('Whatsapp', const Color(0xFF25D366), Icons.chat_outlined),
      ('Linkedin', const Color(0xFF0A66C2), Icons.business_center_outlined),
      ('Pinterest', const Color(0xFFBD081C), Icons.push_pin_outlined),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share to',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              children: [
                for (final (name, color, icon) in items)
                  InkWell(
                    onTap: () => _share(context, name),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(icon, color: Colors.white, size: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(name,
                            style:
                                Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
