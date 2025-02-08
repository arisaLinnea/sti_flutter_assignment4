import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserApp {
  final int id;
  final String username;
  final String email;
  final String apiToken;

  const UserApp(this.id, this.username, this.email, this.apiToken);
}
