import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/failure_message.dart';
import 'package:app_test_e2e/core/utils/validators.dart';
import 'package:app_test_e2e/presentation/navigation/app_routes.dart';
import 'package:app_test_e2e/presentation/pages/login/login_keys.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:app_test_e2e/presentation/widgets/app_button.dart';
import 'package:app_test_e2e/presentation/widgets/app_error_banner.dart';
import 'package:app_test_e2e/presentation/widgets/app_input.dart';
import 'package:app_test_e2e/presentation/widgets/app_password_input.dart';
import 'package:app_test_e2e/presentation/widgets/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref
        .read(loginNotifierProvider.notifier)
        .login(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final failure = state.error;

    return AuthLayout(
      key: LoginKeys.page,
      title: 'Bem-vindo de volta',
      subtitle: 'Entre para ver suas tarefas.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure is Failure) ...[
                AppErrorBanner(key: LoginKeys.error, message: failure.message),
                const SizedBox(height: 16),
              ],
              AppInput(
                key: LoginKeys.email,
                controller: _email,
                label: 'E-mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 16),
              AppPasswordInput(
                key: LoginKeys.password,
                controller: _password,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (value) =>
                    Validators.required(value, message: 'Informe sua senha.'),
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 24),
              AppButton(
                key: LoginKeys.submit,
                label: 'Entrar',
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              TextButton(
                key: LoginKeys.goToRegister,
                onPressed: state.isLoading
                    ? null
                    : () => context.push(AppRoutes.register),
                child: const Text('Ainda não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
