import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/widgets/photo_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../lifestyle/presentation/cubit/lifestyle_cubit.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import '../cubit/create_listing_cubit.dart';
import '../widgets/host_badge.dart';

/// "List your place" — lets a student sublet a room or a letting agent post a
/// whole property. A student room carries the host's questionnaire answers so
/// browsers get a real compatibility score rather than a placeholder.
class CreateListingPage extends StatelessWidget {
  const CreateListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreateListingCubit(createListing: sl(), photoService: sl()),
      child: const _CreateListingView(),
    );
  }
}

class _CreateListingView extends StatefulWidget {
  const _CreateListingView();

  @override
  State<_CreateListingView> createState() => _CreateListingViewState();
}

/// Stateful only to own the form controllers.
class _CreateListingViewState extends State<_CreateListingView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _contactName.text = user?.username ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _address,
      _price,
      _description,
      _contactName,
      _contactPhone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  String? _priceValidator(String? value) {
    final basic = _required(value, 'Monthly rent');
    if (basic != null) return basic;
    final parsed = num.tryParse(value!.trim());
    if (parsed == null) return 'Enter a number';
    if (parsed <= 0) return 'Rent must be more than zero';
    return null;
  }

  /// Photos chosen from the gallery, still on the device. They are uploaded
  /// when the form is submitted, not when they are picked, so a student can
  /// change their mind without burning an upload.
  final _photos = <String>[];
  bool _pickingPhotos = false;

  Future<void> _addPhotos() async {
    setState(() => _pickingPhotos = true);
    try {
      final picked = await sl<PhotoService>().pick(limit: 6 - _photos.length);
      if (!mounted) return;
      setState(() => _photos.addAll(picked));
    } on ServerException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _pickingPhotos = false);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Add at least one photo')));
      return;
    }

    context.read<CreateListingCubit>().submit(
      name: _name.text.trim(),
      address: _address.text.trim(),
      description: _description.text.trim(),
      pricePerMonth: num.parse(_price.text.trim()),
      contactName: _contactName.text.trim(),
      contactPhone: _contactPhone.text.trim(),
      images: List.of(_photos),
      hostLifestyle: context.read<LifestyleCubit>().state.profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<CreateListingCubit, CreateListingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateListingStatus.success) {
          // Refresh the catalogue so the new listing appears immediately.
          context.read<PropertyBloc>().add(const PropertiesRequested());
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Your listing is live')),
            );
          Navigator.of(context).pop();
        } else if (state.status == CreateListingStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateListingCubit>();

        return Scaffold(
          appBar: AppBar(title: const Text('List your place')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const _SectionLabel('Who is listing?'),
                  Row(
                    children: [
                      for (final type in HostType.values) ...[
                        Expanded(
                          child: _ChoiceCard(
                            icon: HostBadge.iconFor(type),
                            title: type.label,
                            subtitle: type.blurb,
                            selected: state.hostType == type,
                            onTap: () => cubit.setHostType(type),
                          ),
                        ),
                        if (type != HostType.values.last)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),

                  const _SectionLabel('What are you offering?'),
                  for (final kind in ListingKind.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChoiceCard(
                        icon: kind == ListingKind.housemate
                            ? Icons.people_outline
                            : Icons.home_work_outlined,
                        title: kind.label,
                        subtitle: kind == ListingKind.housemate
                            ? 'Browsers see a compatibility score with you'
                            : 'No housemate matching — the place is empty',
                        selected: state.listingKind == kind,
                        // A letting agent cannot offer a housemate room.
                        onTap:
                            state.hostType == HostType.realtor &&
                                kind == ListingKind.housemate
                            ? null
                            : () => cubit.setListingKind(kind),
                      ),
                    ),

                  if (state.attachesLifestyle)
                    BlocBuilder<LifestyleCubit, LifestyleState>(
                      builder: (context, lifestyle) => _Callout(
                        icon: lifestyle.hasProfile
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        text: lifestyle.hasProfile
                            ? 'Your lifestyle answers will be attached so '
                                  'students see why they match you.'
                            : 'Take the lifestyle questionnaire first and '
                                  'students will see a real match score.',
                      ),
                    ),

                  const _SectionLabel('About the place'),
                  AppTextField(
                    controller: _name,
                    label: 'Listing title',
                    hint: 'Bright room near the ALU shuttle',
                    validator: (v) => _required(v, 'A title'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _address,
                    label: 'Address',
                    hint: 'KG 11 Ave, Gasabo, Kigali',
                    validator: (v) => _required(v, 'An address'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _price,
                    label: 'Monthly rent (USD)',
                    hint: '120',
                    keyboardType: TextInputType.number,
                    validator: _priceValidator,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _Stepper(
                          label: 'Bedrooms',
                          value: state.bedrooms,
                          onChanged: cubit.setBedrooms,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Stepper(
                          label: 'Bathrooms',
                          value: state.bathrooms,
                          onChanged: cubit.setBathrooms,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Photos',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The first photo becomes the cover. Up to six.',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: 12),
                  PhotoPickerField(
                    photos: _photos,
                    busy: _pickingPhotos,
                    onAdd: _addPhotos,
                    onRemove: (path) => setState(() => _photos.remove(path)),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Description',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _description,
                    maxLines: 5,
                    maxLength: 400,
                    validator: (v) => _required(v, 'A description'),
                    decoration: const InputDecoration(
                      hintText: 'Who lives here, what is nearby, house rules…',
                    ),
                  ),

                  const _SectionLabel('How should people reach you?'),
                  AppTextField(
                    controller: _contactName,
                    label: 'Contact name',
                    hint: 'Your name',
                    validator: (v) => _required(v, 'A contact name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _contactPhone,
                    label: 'Phone',
                    hint: '+250 7…',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: (v) => _required(v, 'A phone number'),
                  ),

                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Publish listing',
                    busy: state.busy,
                    onPressed: () => _submit(context),
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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  /// Null disables the card — used when a choice is not valid for the
  /// currently selected host type.
  final VoidCallback? onTap;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryFaint : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
                color: AppColors.primary,
              ),
              Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: value < 10 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Callout extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Callout({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
