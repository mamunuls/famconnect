import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:famconnect/features/auth/ui/screens/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String name = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailTEController.text.trim(),
            password: _passwordTEController.text.trim(),
          );
      final user = userCredential.user;
      await user!.updateDisplayName(_nameTEController.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameTEController.text.trim(),
        'email': _emailTEController.text.trim(),
      });
      await user.sendEmailVerification();
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Verify Your Email"),
              content: const Text(
                "We've sent a verification link to your email. Please verify before logging in.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pushReplacementNamed(context, LogInScreen.name);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration failed")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 88),
            const SizedBox(height: 24),
            Text(
              'Create an Account',
              style: GoogleFonts.dynaPuff(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register to get started!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            buildForm(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : () => register(context),
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Sign Up"),
            ),
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
            controller: _nameTEController,
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator:
                (value) => value!.trim().isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailTEController,

            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value!.trim().isEmpty) return 'Enter your email';

              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email';
              }

              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordTEController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed:
                    () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
              ),
            ),
            validator: (value) {
              if (value!.length < 8)
                return 'Password must be at least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: _confirmPasswordTEController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (String? value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Confirm your password';
              }
              if (value != _passwordTEController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
