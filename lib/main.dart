import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart'; 
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'app/data/services/local_db_service.dart';
import 'app/data/services/ai_receipt_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Handler untuk background message HARUS berupa top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  // Note: Jangan lakukan UI update di sini.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables dari file .env
  await dotenv.load(fileName: ".env");
  
  // Inisialisasi GetStorage dan DateFormatting dari kodemu
  await GetStorage.init();
  await initializeDateFormatting('id', null);

  // Inisialisasi SQLite Cache DB
  await Get.putAsync(() => LocalDbService().init());
  
  // Inisialisasi AI Service
  Get.put(AiReceiptService());

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Daftarkan background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Meminta izin notifikasi (Penting untuk iOS dan Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Ubah runApp agar memanggil widget MyApp yang stateful
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupForegroundMessaging();
  }

  void _setupForegroundMessaging() {
    // Handler untuk foreground message (saat aplikasi sedang dibuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification?.title}');
        
        // Memunculkan in-app snackbar menggunakan GetX
        Get.snackbar(
          message.notification?.title ?? 'Notifikasi Baru',
          message.notification?.body ?? '',
          backgroundColor: AppColors.bgWhite, // Sesuaikan dengan theme kamu
          colorText: Colors.black87,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Masukkan GetMaterialApp aslimu ke dalam fungsi build ini
    return GetMaterialApp(
      title: "My Project Mobile",
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgWhite,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
        fontFamily: 'Sans-Serif',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id'), Locale('en')],
    );
  }
}