import 'package:app_test_e2e/core/utils/failure.dart';
import 'package:app_test_e2e/core/utils/failure_message.dart';
import 'package:app_test_e2e/core/utils/validators.dart';
import 'package:app_test_e2e/presentation/pages/register/register_keys.dart';
import 'package:app_test_e2e/presentation/providers/auth/auth_provider.dart';
import 'package:app_test_e2e/presentation/widgets/app_button.dart';
import 'package:app_test_e2e/presentation/widgets/app_error_banner.dart';
import 'package:app_test_e2e/presentation/widgets/app_input.dart';
import 'package:app_test_e2e/presentation/widgets/app_password_input.dart';
import 'package:app_test_e2e/presentation/widgets/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref
        .read(registerNotifierProvider.notifier)
        .register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
  }

  String? _validateConfirmation(String? value) =>
      value == _password.text ? null : 'As senhas não conferem.';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerNotifierProvider);
    final failure = state.error;
    final enabled = !state.isLoading;

    return AuthLayout(
      key: RegisterKeys.page,
      title: 'Crie sua conta',
      subtitle: 'Leva menos de um minuto.',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (failure is Failure) ...[
                AppErrorBanner(
                  key: RegisterKeys.error,
                  message: failure.message,
                ),
                const SizedBox(height: 16),
              ],
              AppInput(
                key: RegisterKeys.name,
                controller: _name,
                label: 'Nome',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: (value) =>
                    Validators.required(value, message: 'Informe seu nome.'),
                enabled: enabled,
              ),
              const SizedBox(height: 16),
              AppInput(
                key: RegisterKeys.email,
                controller: _email,
                label: 'E-mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                enabled: enabled,
              ),
              const SizedBox(height: 16),
              AppPasswordInput(
                key: RegisterKeys.password,
                controller: _password,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                enabled: enabled,
              ),
              const SizedBox(height: 16),
              AppPasswordInput(
                key: RegisterKeys.passwordConfirmation,
                controller: _passwordConfirmation,
                label: 'Confirme a senha',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: _validateConfirmation,
                enabled: enabled,
              ),
              const SizedBox(height: 24),
              AppButton(
                key: RegisterKeys.submit,
                label: 'Criar conta',
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
