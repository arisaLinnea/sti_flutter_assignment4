import 'package:intl/intl.dart';

extension FormatParsing on DateTime {
  String parkingFormat() {
    var formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(this);
  }
}
