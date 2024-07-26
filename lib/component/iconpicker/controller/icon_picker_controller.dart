import 'package:flutter/material.dart';

class IconPickerController with ChangeNotifier{
  updateState(){
    notifyListeners();
  }

  late IconData selectedIconData;
  setSelectedIconData(IconData data){
    selectedIconData = data;
    notifyListeners();
  }
}