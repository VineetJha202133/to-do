import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:todo/module/auth_module/screens/auth_screen.dart';
import 'package:todo/module/home_module/screens/home_screen.dart';
import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/services/local_notification.dart';
import 'package:todo/services/shared_preferences_services.dart';
import 'package:todo/utils/enum/shared_prefs_keys_enum.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LocalNotification.initLocalPlugin();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool>? _isLoginFuture;

  @override
  void initState() {
    super.initState();
    _isLoginFuture = isLoginCheck();
  }

  Future<bool> isLoginCheck() async {
    return await SharedPreferencesServices.getBoolData(
            key: SharedPreferencesKeyEnum.isLoggedIn.value) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          bool isLogin = snapshot.data ?? false;

          var lightTheme = ThemeData.light().copyWith(
            textTheme: TextTheme(
              displayLarge: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
              titleMedium: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              bodyLarge: TextStyle(
                  fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
            ),
          );

          return ScopedModel<TodoListModel>(
            model: TodoListModel(),
            child: MaterialApp(
              title: 'Todo',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              theme: lightTheme,
              home: isLogin ? MyHomePage(title: '') : AuthScreen(),
            ),
          );
        }
      },
    );
  }
}
