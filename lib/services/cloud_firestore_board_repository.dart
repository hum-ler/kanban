import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/board_data.dart';
import 'board_repository.dart';

/// The repository for Kanban board data using Google Firebase Cloud Firestore.
class CloudFirestoreBoardRepository implements BoardRepository {
  /// The Cloud Firestore data provider.
  final _CloudFirestoreBoardProvider _provider = _CloudFirestoreBoardProvider();

  @override
  Future<BoardData> load(String id) => _provider.load(id);

  @override
  Future<BoardData> save(BoardData data) => _provider.save(data);

  @override
  Future<void> delete(String id) => _provider.delete(id);
}

/// The Cloud Firestore data provider.
class _CloudFirestoreBoardProvider {
  /// Loads the Kanban board with ID [id].
  Future<BoardData> load(String id) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('boards')
        .doc(id)
        .get()
        .then((value) => BoardData.fromJson(value.data()!));
  }

  /// Saves the Kanban board.
  Future<BoardData> save(BoardData data) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Wait for the save to be confirmed before returning the data.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('boards')
        .doc(data.id)
        .set(data.toJson());

    return data;
  }

  /// Deletes the Kanban board with ID [id].
  Future<void> delete(String id) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('boards')
        .doc(id)
        .delete();
  }
}
