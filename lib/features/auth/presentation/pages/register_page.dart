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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Stateful only for controller/form lifecycle — all UI state changes go
/// through cubits/blocs, never setState.
class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, bool agreed) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!agreed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please agree with the terms and privacy policy.'),
          ),
        );
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ToggleCubit(true)), // obscure password
        BlocProvider(create: (_) => TermsCubit(true)), // terms agreed
      ],
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
            // New students go straight into the lifestyle questionnaire: the
            // compatibility score is the product, and it is meaningless until
            // the answers exist. The quiz hands off to the location step.
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.quiz, (route) => false);
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
                      'Register Account',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up with your university email to join\na verified student community',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Email',
                      hint: 'name@alustudent.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.studentEmail,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Username',
                      hint: 'Username',
                      controller: _usernameController,
                      validator: Validators.username,
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
                    const SizedBox(height: 18),
                    BlocBuilder<TermsCubit, bool>(
                      builder: (context, agreed) => InkWell(
                        onTap: context.read<TermsCubit>().toggle,
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: agreed
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: agreed
                                      ? AppColors.primary
                                      : AppColors.grey,
                                ),
                              ),
                              child: agreed
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            // Wrapped so the consent line can shrink or wrap
                            // instead of overflowing narrow screens.
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Agree with ',
                                  children: [
                                    TextSpan(
                                      text: 'terms',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'privacy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) =>
                            previous.busy != current.busy,
                        builder: (context, state) => PrimaryButton(
                          label: 'Sign up',
                          busy: state.busy,
                          onPressed: () => _submit(
                            context,
                            context.read<TermsCubit>().state,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SocialButtons(),
                    const SizedBox(height: 24),
                    Center(
                      child: InkWell(
                        onTap: () => Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.signIn),
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account ? ',
                            children: const [
                              TextSpan(
                                text: 'Sign in',
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

/// Separate type so both cubits can live in the same provider scope.
class TermsCubit extends ToggleCubit {
  TermsCubit([super.initial]);
}
