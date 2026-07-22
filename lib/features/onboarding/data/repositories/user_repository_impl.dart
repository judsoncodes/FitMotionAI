import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final Map<String, UserProfile> _memoryCache = {};

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _memoryCache[profile.uid] = profile;
    try {
      await _usersCollection.doc(profile.uid).set(
            profile.toMap(),
            SetOptions(merge: true),
          );
    } catch (_) {
      // In-memory fallback if Firestore offline
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    if (_memoryCache.containsKey(uid)) {
      return _memoryCache[uid];
    }

    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final profile = UserProfile.fromMap(doc.data()!);
        _memoryCache[uid] = profile;
        return profile;
      }
    } catch (_) {
      // Fallback
    }

    return _memoryCache[uid];
  }

  @override
  Stream<UserProfile?> userProfileStream(String uid) {
    try {
      return _usersCollection
          .doc(uid)
          .snapshots()
          .map<UserProfile?>((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              final profile = UserProfile.fromMap(snapshot.data()!);
              _memoryCache[uid] = profile;
              return profile;
            }
            return _memoryCache[uid];
          })
          .timeout(
            const Duration(seconds: 3),
            onTimeout: (sink) {
              sink.add(_memoryCache[uid]);
            },
          )
          .handleError((_) => _memoryCache[uid]);
    } catch (_) {
      return Stream.value(_memoryCache[uid]);
    }
  }
}
