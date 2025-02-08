import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_client/shared_client.dart';

abstract class Repository<T extends Identifiable> {
  final String _path;

  final db = FirebaseFirestore.instance;

  Uri uri = Uri(scheme: 'http', host: 'localhost', port: 8080);

  String get path => _path;

  Repository({required String path}) : _path = path;

  Map<String, dynamic> serialize(T item);
  Future<T> deserialize(Map<String, dynamic> json);

  Future<String?> addToList({required T item}) async {
    await db.collection(_path).doc(item.id).set(serialize(item));
    return item.id;
  }

  Future<List<T>> getList() async {
    final snapshot = await db.collection(_path).get();
    final jsons = snapshot.docs.map((doc) => doc.data()).toList();

    final items =
        await Future.wait(jsons.map((item) async => await deserialize(item)));
    return items;
  }

  Future<T?> getElementById({required String id}) async {
    final snapshot = await db.collection(_path).doc(id).get();
    final json = snapshot.data();

    if (json == null) {
      return Future.value(null);
    }

    return deserialize(json);
  }

  Future<bool> update({required String id, required T item}) async {
    await db.collection(_path).doc(id).set(serialize(item));
    return true;
  }

  Future<bool> remove({required String id}) async {
    await db.collection(_path).doc(id).delete();
    return true;
  }
}
