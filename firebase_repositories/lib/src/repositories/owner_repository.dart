import 'package:firebase_repositories/src/repositories/repository.dart';
import 'package:shared_client/shared_client.dart';

class OwnerRepository extends Repository<Owner> {
  static final OwnerRepository _instance =
      OwnerRepository._internal(path: 'owner');

  OwnerRepository._internal({required super.path});

  factory OwnerRepository() => _instance;

  Future<Owner> getElementByAuthId({required String id}) async {
    final snapshot =
        await db.collection(path).where('loginId', isEqualTo: id).get();
    if (snapshot.docs.isEmpty) {
      return Future.value(null);
    }

    final json = snapshot.docs.first.data();

    return deserialize(json);
  }

  @override
  Future<Owner> deserialize(Map<String, dynamic> json) async =>
      Owner.fromJson(json);

  @override
  Map<String, dynamic> serialize(Owner item) => item.toJson();
}
