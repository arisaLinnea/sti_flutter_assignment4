extension StringValidation on String {
  bool isValidEmail() {
    if (isEmpty) {
      return false;
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegExp.hasMatch(this);
  }

  bool isValidSsn() {
    if (isEmpty) {
      return false;
    }
    RegExp ssnRegExp =
        RegExp(r'^(((19|20)?(\d{6}(-|\s)\d{4}))|((19|20)?\d{10}))$');

    return ssnRegExp.hasMatch(this);
  }

  bool isValidPassword() {
    if (isEmpty) {
      return false;
    }
    return true;
  }

  bool isValidRegNo() {
    if (isEmpty) {
      return false;
    }
    RegExp regNoRegexExp = RegExp(r'^([a-zA-Z]{3}[0-9]{2}[a-zA-Z0-9]{1})$');

    return regNoRegexExp.hasMatch(this);
  }
}
