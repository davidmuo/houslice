import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/property_image.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/entities/booking.dart';
import '../bloc/booking_bloc.dart';
import '../cubit/booking_form_cubit.dart';
import '../widgets/booking_success_sheet.dart';
import '../widgets/select_date_sheet.dart';

/// Checkout screen: period, payment method, price details, Confirm and Pay.
class BookingPage extends StatelessWidget {
  final Property property;

  const BookingPage({super.key, required this.property});

  static const _tax = 10;

  void _confirm(BuildContext context, BookingFormState form) {
    context.read<BookingBloc>().add(BookingSubmitted(Booking(
          id: '',
          propertyId: property.id,
          propertyName: property.name,
          propertyAddress: property.address,
          propertyImage: property.coverImage,
          startDate: form.start!,
          endDate: form.end!,
          monthlyPrice: property.pricePerMonth,
          tax: _tax,
          status: BookingStatus.checkin,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => BookingFormCubit(),
      child: BlocListener<BookingBloc, BookingState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == BookingViewStatus.created) {
            showBookingSuccessSheet(context);
          } else if (state.status == BookingViewStatus.failure &&
              state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Booking')),
          body: BlocBuilder<BookingFormCubit, BookingFormState>(
            builder: (context, form) {
              final months = form.hasValidRange
                  ? Formatters.periodMonths(form.start!, form.end!)
                  : 1;
              final subtotal = property.pricePerMonth * months;
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        PropertyImage(
                          url: property.coverImage,
                          width: 96,
                          height: 96,
                          radius: BorderRadius.circular(14),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 15, color: AppColors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      property.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    Formatters.price(
                                        property.pricePerMonth),
                                    style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '/month',
                                    style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.grey),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.star_rounded,
                                      color: AppColors.star, size: 18),
                                  const SizedBox(width: 2),
                                  Text(
                                    property.rating.toStringAsFixed(1),
                                    style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Period',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800, fontSize: 19),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => showSelectDateSheet(
                        context, context.read<BookingFormCubit>()),
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFaint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month_outlined,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: AppColors.grey),
                              ),
                              Text(
                                form.hasValidRange
                                    ? Formatters.range(
                                        form.start!, form.end!)
                                    : 'Choose your dates',
                                style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Make sure to check your date before making any\nsort of payments',
                    style:
                        textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payments',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800, fontSize: 19),
                  ),
                  const SizedBox(height: 8),
                  if (form.method == null) ...[
                    _PaymentOption(
                      icon: Icons.credit_card,
                      label: PaymentMethod.card.label,
                      onTap: () => context
                          .read<BookingFormCubit>()
                          .chooseMethod(PaymentMethod.card),
                    ),
                    const Divider(),
                    _PaymentOption(
                      icon: Icons.phone_iphone,
                      label: PaymentMethod.momo.label,
                      onTap: () => context
                          .read<BookingFormCubit>()
                          .chooseMethod(PaymentMethod.momo),
                    ),
                  ] else
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFaint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            form.method == PaymentMethod.card
                                ? Icons.credit_card
                                : Icons.phone_iphone,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            form.method == PaymentMethod.card
                                ? '...........3321'
                                : 'MTN MoMo — +250 78* *** *11',
                            style: textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              context.read<BookingFormCubit>().editMethod,
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Divider(height: 24),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                          content:
                              Text('Vouchers are coming soon for students'),
                        ));
                    },
                    child: Text(
                      'Enter a Voucher',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Price Details',
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800, fontSize: 19),
                  ),
                  const SizedBox(height: 12),
                  _PriceRow(
                    label: 'Period time',
                    value: '$months Month${months > 1 ? 's' : ''}',
                    emphasized: true,
                  ),
                  _PriceRow(
                    label: 'Monthly payment',
                    value: Formatters.money(subtotal),
                    emphasized: true,
                  ),
                  _PriceRow(
                    label: 'Tax',
                    value: Formatters.money(_tax),
                    emphasized: true,
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(
                        'Total',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.money(subtotal + _tax),
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<BookingBloc, BookingState>(
                    buildWhen: (previous, current) =>
                        previous.status != current.status,
                    builder: (context, bookingState) => PrimaryButton(
                      label: 'Confirm and Pay',
                      busy:
                          bookingState.status == BookingViewStatus.creating,
                      onPressed: form.canConfirm
                          ? () => _confirm(context, form)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.add, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
