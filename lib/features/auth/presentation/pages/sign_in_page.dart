import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/toggle_cubit.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/social_buttons.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

/// Stateful only for controller/form lifecycle.
class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (_) => ToggleCubit(true),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.error != current.error ||
            previous.status != current.status,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          } else if (state.status == AuthStatus.authenticated) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
          }
        },
        child: Scaffold(
          appBar: AppBar(centerTitle: false),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with your email and password\nor social media to continue',
                      style:
                          textTheme.bodyLarge?.copyWith(color: AppColors.grey),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Email',
                      hint: 'name@alustudent.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<ToggleCubit, bool>(
                      builder: (context, obscure) => AppTextField(
                        label: 'Password',
                        hint: 'Password',
                        controller: _passwordController,
                        obscure: obscure,
                        onToggleObscure: context.read<ToggleCubit>().toggle,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.busy != current.busy,
                      builder: (context, state) => PrimaryButton(
                        label: 'Sign in',
                        busy: state.busy,
                        onPressed: () => _submit(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SocialButtons(),
                    const SizedBox(height: 24),
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.register),
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account ? ",
                            children: const [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: textTheme.bodyMedium,
                        ),
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
