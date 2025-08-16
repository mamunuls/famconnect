import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famconnect/features/auth/ui/screens/login_screen.dart';
import 'package:famconnect/features/common/ui/widgets/custom_snakebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackBarMessage(
        context,
        "Password reset email sent. Check your inbox.",
      );
    } on FirebaseAuthException catch (e) {
      showSnackBarMessage(
        context,
        e.message ?? "Error sending reset email.",
        true,
      );
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception("User data not found");
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Failed to fetch user data: $e");
    }
  }


  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user!.updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            'uid': userCred.user!.uid,
            'name': name,
            'email': email,
            'createdAt': Timestamp.now(),
          });
      await userCred.user!.sendEmailVerification();
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
                    Navigator.pushReplacementNamed(context, '/log-in');
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      showSnackBarMessage(context, e.message ?? "Registration failed", true);
    }
  }

  Future<void> signin(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCred.user!.reload();

      if (userCred.user!.emailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', userCred.user!.uid);
        await prefs.setString('name', userCred.user!.displayName ?? "");
        await prefs.setString('email', userCred.user!.email ?? "");

        Navigator.pushReplacementNamed(context, '/home-screen');
      } else {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      showSnackBarMessage(context, e.message ?? "Login failed", true);
    }
  }

  Future<void> signout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogInScreen()),
      );
    }
  }
}
