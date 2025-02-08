import 'package:shared_client/src/models/identifiable.dart';
import 'package:uuid/uuid.dart';

class Owner implements Identifiable {
  String _id;
  String? loginId;
  String name;
  String ssn;

  Owner({required this.name, required this.ssn, this.loginId, String? id})
      : _id = id ?? Uuid().v4();

  @override
  String get id => _id;

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      loginId: json['loginId'] ?? "",
      name: json['name'],
      ssn: json['ssn'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'loginId': loginId,
        'name': name,
        'ssn': ssn,
      };

  @override
  String toString() {
    return 'Name: $name, ssn: $ssn, id: $_id';
  }

  bool isValid() {
    return true;
  }
}
