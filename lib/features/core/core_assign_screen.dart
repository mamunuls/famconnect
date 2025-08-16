import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssignTaskScreen extends StatefulWidget {
  final String userName;
  final DateTime date;
  final String timeRange;

  const AssignTaskScreen({
    Key? key,
    required this.userName,
    required this.date,
    required this.timeRange,
  }) : super(key: key);

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  bool _isSaving = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;


  Future<void> _saveTask() async {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task description')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save task linked to user and free time slot
      await _firestore
          .collection('tasks')
          .doc(user!.uid)
          .set({
            'userName': widget.userName,
            'date': Timestamp.fromDate(widget.date),
            'timeRange': widget.timeRange,
            'taskDescription': taskText,
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task assigned successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to assign task: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign task for: ${widget.userName}'),
            Text('Date: ${widget.date.toLocal().toString().split(' ')[0]}'),
            Text('Free Time: ${widget.timeRange}'),
            const SizedBox(height: 20),
            TextField(
              controller: _taskController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text('Save Task'),
                ),
          ],
        ),
      ),
    );
  }
}
