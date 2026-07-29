import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

/// "Add New Card" from the Figma.
///
/// Deliberately does **not** persist or transmit the card. Houseslice has no
/// PCI-compliant payment processor wired up, so storing a real card number
/// would be worse than not offering the screen at all. The details are used
/// only to render the card preview and are discarded when the page closes;
/// the last four digits are handed back to the checkout screen so the chosen
/// method can be displayed.
class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

/// Stateful only for the controllers driving the live card preview.
class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The preview mirrors what is typed, so every field triggers a repaint.
    for (final c in [_name, _number, _expiry]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _number, _expiry, _cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  String? _validateNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Card number is required';
    if (digits.length < 13 || digits.length > 19) {
      return 'Enter a valid card number';
    }
    if (!_passesLuhn(digits)) return 'That card number is not valid';
    return null;
  }

  /// Luhn checksum — the standard card-number sanity check. Catches typos
  /// before anything is submitted.
  static bool _passesLuhn(String digits) {
    var sum = 0;
    var double = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);
      if (double) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      double = !double;
    }
    return sum % 10 == 0;
  }

  String? _validateExpiry(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Expiry is required';
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v);
    if (match == null) return 'Use MM/YY';

    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'Month must be 01-12';

    // Cards are valid through the last day of their expiry month.
    final expires = DateTime(year, month + 1, 0);
    if (expires.isBefore(DateTime.now())) return 'That card has expired';
    return null;
  }

  String? _validateCvv(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'CVV is required';
    if (!RegExp(r'^\d{3,4}$').hasMatch(v)) return 'CVV is 3 or 4 digits';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final last4 = _digits.substring(_digits.length - 4);
    // Only the masked tail leaves this screen.
    Navigator.of(context).pop(last4);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _CardPreview(
                name: _name.text,
                digits: _digits,
                expiry: _expiry.text,
              ),
              const SizedBox(height: 28),

              AppTextField(
                controller: _name,
                label: 'Name on card',
                hint: 'John Simmons',
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name on card is required'
                    : null,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _number,
                label: 'Card number',
                hint: '1234 5678 9101 1121',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  _CardNumberFormatter(),
                ],
                validator: _validateNumber,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _expiry,
                      label: 'Expires',
                      hint: 'MM/YY',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppTextField(
                      controller: _cvv,
                      label: 'CVV',
                      hint: '123',
                      keyboardType: TextInputType.number,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: _validateCvv,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFaint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This milestone does not process payments. Your card '
                        'details are not saved or sent anywhere — only the '
                        'last four digits are kept, to label the method.',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              PrimaryButton(label: 'Add card', onPressed: _submit),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live preview of the card being typed, matching the Figma mock.
class _CardPreview extends StatelessWidget {
  final String name;
  final String digits;
  final String expiry;

  const _CardPreview({
    required this.name,
    required this.digits,
    required this.expiry,
  });

  /// Groups digits into 4s and pads the remainder with bullets.
  String get _formattedNumber {
    final padded = digits.padRight(16, '•').substring(0, 16);
    return [
      for (var i = 0; i < 16; i += 4) padded.substring(i, i + 4),
    ].join('  ');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B2FF7), Color(0xFFB24592)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Credit Card',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              const Icon(Icons.credit_card, color: Colors.white70, size: 26),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formattedNumber,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? 'CARDHOLDER NAME' : name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                expiry.isEmpty ? 'MM/YY' : expiry,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Inserts a space every four digits as the number is typed.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Turns `1226` into `12/26` as it is typed.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
