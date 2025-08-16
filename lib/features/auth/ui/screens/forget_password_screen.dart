import 'package:famconnect/features/auth/services/auth_service.dart';
import 'package:famconnect/features/auth/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String name = '/forgot-password-screen';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 88),
              const SizedBox(height: 24),
              Text(
                'Oops!',
                style: GoogleFonts.dynaPuff(
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                ),
              ),
              Text(
                'Forgot your password?',
                style: GoogleFonts.dynaPuff(
                  color:
                      Theme.of(context).textTheme.titleSmall?.color ??
                      Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon:  Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            await _authService.resetPassword(
                              _emailController.text,
                              context,
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              LogInScreen.name,
                            );

                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
