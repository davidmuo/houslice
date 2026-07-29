import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// "Edit Profile" from the Figma — name, username, date of birth.
///
/// Email is shown but not editable: it is the verified university identity the
/// whole account rests on, so changing it would mean re-verifying enrolment.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

/// Stateful only for the controllers and the picked date.
class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  DateTime? _dateOfBirth;

  static final _dateFormat = DateFormat('MMMM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _name.text = user?.username ?? '';
    _username.text = (user?.username ?? '').replaceAll(' ', '').toLowerCase();
    final stored = user?.dateOfBirth;
    if (stored != null) _dateOfBirth = DateTime.tryParse(stored);
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      // Students are realistically between 16 and 80.
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 16),
      helpText: 'Date of birth',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthProfileUpdateRequested(
        username: _name.text.trim(),
        dateOfBirth: _dateOfBirth?.toIso8601String().split('T').first,
      ),
    );
  }

  String? _required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.notice != current.notice || previous.error != current.error,
      listener: (context, state) {
        final message = state.error ?? state.notice;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        if (state.error == null) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryFaint,
                          foregroundImage: user?.photoUrl == null
                              ? null
                              : NetworkImage(user!.photoUrl!),
                          onForegroundImageError: user?.photoUrl == null
                              ? null
                              : (_, _) {},
                          child: Text(
                            user?.initials ?? '?',
                            style: textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  AppTextField(
                    controller: _name,
                    label: 'Full name',
                    hint: 'John Simmons',
                    validator: (v) => _required(v, 'Your name'),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    controller: _username,
                    label: 'Username',
                    hint: 'johnsim',
                    validator: (v) => _required(v, 'A username'),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Email',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ReadOnlyField(
                    value: user?.email ?? '',
                    trailing: user?.emailVerified == true
                        ? const Icon(
                            Icons.verified,
                            size: 18,
                            color: AppColors.success,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your university email verifies you as a student and '
                    'cannot be changed here.',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Date of birth',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dateOfBirth == null
                                  ? 'Select your date of birth'
                                  : _dateFormat.format(_dateOfBirth!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _dateOfBirth == null
                                  ? textTheme.bodyLarge?.copyWith(
                                      color: AppColors.grey,
                                    )
                                  : textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Save Change',
                    busy: state.busy,
                    onPressed: () => _save(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final Widget? trailing;

  const _ReadOnlyField({required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
