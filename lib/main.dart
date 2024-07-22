import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:driver/page/notification/incoming_notification_page.dart';
import 'package:driver/page/splash/splash_page.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:driver/utils/time_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_colors.dart';
import 'constants/app_style.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'language/app_localizations.dart';
import 'model/firebase/firebase_order_response.dart';
import 'navigation/navigation_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyB0TVoTBaKEJwu0tMaNPwAL6-JqCjH394M',
      appId: '1:929593739104:android:d4c8861245e7f1c3060005',
      messagingSenderId: '929593739104',
      projectId: 'oiaway',
      storageBucket: 'oiaway.appspot.com',
    ),
  );
  // Handle background message
  playOrderSound();
  PreferenceUtils.saveNotificationData(message.data);

}

final AudioPlayer _audioPlayer = AudioPlayer();


playOrderSound() async {
  await _audioPlayer.play(AssetSource("sound/order.wav"));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyB0TVoTBaKEJwu0tMaNPwAL6-JqCjH394M',
        appId: '1:929593739104:android:d4c8861245e7f1c3060005',
        messagingSenderId: '929593739104',
        projectId: 'oiaway',
        storageBucket: 'oiaway.appspot.com',
      ),
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    initializeService();
  }
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // // auto start service
      // autoStart: true,
      //
      // // this will be executed when app is in foreground in separated isolate
      // onForeground: onStart,
      //
      // // you have to enable background fetch capability on xcode project
      // onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "4Square Driver Service",
          content: "Updated at ${TimeUtils.convertDateTime(DateTime.now())}",
        );
      }
    }

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //  playOrderSound();
    //  PreferenceUtils.saveNotificationData(message.data);
    // });

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
   // final deviceInfo = DeviceInfoPlugin();
   //  String? device;
   //  if (Platform.isAndroid) {
   //    final androidInfo = await deviceInfo.androidInfo;
   //    device = androidInfo.model;
   //  } else if (Platform.isIOS) {
   //    final iosInfo = await deviceInfo.iosInfo;
   //    device = iosInfo.model;
   //  }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "Android",
      },
    );
  });
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp>  {

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    FlutterFlowTheme.saveThemeMode(mode);
  });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened app");
    });
  }


  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayColor: Colors.grey.withOpacity(0.5),
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) { //ignored progress for the moment
        return Center(
          child: SpinKitThreeBounce(
            color: AppColors.themeColor,
            size: 50.0,
          ),
        );
      },
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey, // set property
        locale: Locale('en'), // Default locale
        supportedLocales: [
          Locale('en', ''),
          Locale('es', ''),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(brightness: Brightness.light),
        themeMode: ThemeMode.light,
        title: 'Thee4square',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
          useMaterial3: true,
          fontFamily: AppStyle.robotoRegular,

        ),
        home: SplashPage(),
      ),
    );
  }

}
