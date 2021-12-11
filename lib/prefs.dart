import 'package:shared_preferences/shared_preferences.dart';

class MyShredPrefsN {
  static getNumber(String a) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(a);
  }

  static addNumber(String a, String b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(a, b);
  }

  static deleteKey() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('Key');
  }
}
