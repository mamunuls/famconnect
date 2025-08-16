import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famconnect/features/common/ui/widgets/custom_snakebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({super.key});

  static const String name = '/update-name-screen';

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final TextEditingController _firstNameTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadCurrentName();
  }

  Future<void> _loadCurrentName() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _firstNameTEController.text = data['name'] ?? '';
        }
      }
    } catch (e) {
      showSnackBarMessage(context, "Error loading name: $e", true);
    }
  }

  Future<void> _updateName() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final updatedName = _firstNameTEController.text.trim();
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': updatedName,
      });
      showSnackBarMessage(context, "Name updated successfully.");
      Navigator.pop(context);
    } catch (e) {
      showSnackBarMessage(context, "Failed to update name: $e", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
        Theme.of(context).brightness == Brightness.dark
            ? Colors
            .white
            : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 88),
            const SizedBox(height: 24),
            Text('Update Name', style: GoogleFonts.dynaPuff(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color:
              Theme.of(context).textTheme.titleLarge?.color ??
                  Colors.white,
            ),),
            const SizedBox(height: 24),
            buildForm(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateName,
              child: const Text('Update Name'),
            ),
          ],
        ),
      ),
    );
  }

  Form buildForm() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _firstNameTEController,
        decoration: const InputDecoration(
          hintText: 'Full Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    );
  }
}
