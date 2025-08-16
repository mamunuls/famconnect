import 'package:famconnect/app/app_colors.dart';
import 'package:famconnect/features/auth/services/auth_service.dart';
import 'package:famconnect/features/auth/ui/screens/forget_password_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  static const String name = '/log-in';

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }

  Future<void> _onTapSigninButton() async {
    if (!_formKey.currentState!.validate()) return;

    await AuthService().signin(
      _emailTEController.text.trim(),
      _passwordTEController.text,
      context,
    );
  }

  void _onTapSignUp() {
    Get.toNamed('/sign-up');
  }

  void _onTapForgetPasswordButton() {
    Get.to(() => const ForgotPasswordScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 88),
            const SizedBox(height: 24),
            Text(
              'Welcome!',
              style: GoogleFonts.dynaPuff(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.white,
              ),
            ),
            Text(
              'Let’s Get You In',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            buildForm(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onTapSigninButton,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _onTapForgetPasswordButton,
              child: const Text(
                'Forgot your password?',
                style: TextStyle(color: AppColors.themeColor),
              ),
            ),
            _buildSignUpSection(),
          ],
        ),
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailTEController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter your email';
              if (!value.contains('@') || !value.contains('.'))
                return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordTEController,
            obscureText: _obscurePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Enter your password';
              if (value.length < 8)
                return 'Password must be at least 8 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpSection() {
    return RichText(
      text: TextSpan(
        text: "Don't have an account? ",
        style: TextStyle(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: 'Sign up',
            style: const TextStyle(color: AppColors.themeColor),
            recognizer: TapGestureRecognizer()..onTap = _onTapSignUp,
          ),
        ],
      ),
    );
  }
}
