import 'package:flutter/material.dart';
import 'package:todo/db/db_provider.dart';
import 'package:todo/module/auth_module/screens/auth_screen.dart';
import 'package:todo/services/shared_preferences_services.dart';
import 'package:todo/utils/enum/shared_prefs_keys_enum.dart';

class HomeScreenController with ChangeNotifier {
  int currentPageIndex = 0;
  setCurrentPageIndex(int index) {
    currentPageIndex = index;
    notifyListeners();
  }

  Future<void> updateLoggedInStatus(bool status) async {
    print('im here');
    await SharedPreferencesServices.setBoolData(
        key: SharedPreferencesKeyEnum.isLoggedIn.value, value: status);
  }

  Future<void> deleteDatabase(BuildContext context) async {
    try {
      await DBProvider.db.clearDatabase();
      updateLoggedInStatus(false);
      notifyListeners();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(),
          ));
      print("Database deleted successfully.");
    } catch (e) {
      print("Error deleting database: $e");
    }
  }
}
