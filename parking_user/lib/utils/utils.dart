import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void toastMessage(String message, {int time = 1}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: time);
  }
}
