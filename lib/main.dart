import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/login_and_register/login.dart';
import 'package:myapp/pages/waitingPage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//del
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

//end
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //Today 5/26/2024
  // Enable debug provider for App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    webProvider: ReCaptchaV3Provider(
      '6LdDSugpAAAAAB8cg_TxcwbLu8U_60IrgkW9zPMJ', // Replace with your actual site key
    ),
  );
//end

  //del
  tz.initializeTimeZones();
  await _initializeNotifications();
  //end

  runApp(MyApp());
}

//del

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await _scheduleDailyTask();
}

Future<void> _scheduleDailyTask() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Daily Task',
    'Updating Available field',
    _nextInstanceOfMidnight(),
    const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily notification channel id', 'daily notification channel name',
          channelDescription: 'daily notification description'),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime _nextInstanceOfMidnight() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 0);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

Future<void> updateAvailableField() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final QuerySnapshot userSnapshot = await _firestore.collection('User').get();
  final WriteBatch batch = _firestore.batch();

  for (final QueryDocumentSnapshot doc in userSnapshot.docs) {
    final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    final String dailyQuota = userData['Daily Quota'];
    batch.update(doc.reference, {'Available': dailyQuota});
  }

  await batch.commit();
  print('Available field updated for all users');
}

Future<void> backgroundTask() async {
  await updateAvailableField();
}
//end

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
