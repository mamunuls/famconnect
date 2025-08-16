import 'package:famconnect/app/fam_connect_app.dart';
import 'package:famconnect/features/event_create/ui/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(FamConnectApp());
}

