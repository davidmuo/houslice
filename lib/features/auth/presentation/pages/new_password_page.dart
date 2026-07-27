import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';

/// "Create New Password" screen from the Figma design.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context
        .read<AuthBloc>()
        .add(AuthPasswordChangeRequested(_passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => ToggleCubit(true),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.error != current.error ||
            previous.notice != current.notice,
        listener: (context, state) {
          final message = state.error ?? state.notice;
          if (message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
          if (state.notice != null) Navigator.of(context).pop();
        },
        child: Scaffold(
          appBar: AppBar(centerTitle: false),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Password',
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter a new password\nto change',
                      style:
                          textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                    ),
                    const SizedBox(height: 28),
                    BlocBuilder<ToggleCubit, bool>(
                      builder: (context, obscure) => Column(
                        children: [
                          AppTextField(
                            label: 'New Password',
                            hint: 'Password',
                            controller: _passwordController,
                            obscure: obscure,
                            onToggleObscure:
                                context.read<ToggleCubit>().toggle,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            label: 'Confirm Password',
                            hint: 'Password',
                            controller: _confirmController,
                            obscure: obscure,
                            onToggleObscure:
                                context.read<ToggleCubit>().toggle,
                            validator: (value) => Validators.confirmPassword(
                                value, _passwordController.text),
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.busy != current.busy,
                      builder: (context, state) => PrimaryButton(
                        label: 'Change password',
                        busy: state.busy,
                        onPressed: () => _submit(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
