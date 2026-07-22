import '../models/user_profile.dart';

abstract class UserRepository {
  /// Save or update user profile in Cloud Firestore
  Future<void> saveUserProfile(UserProfile profile);

  /// Fetch user profile from Cloud Firestore by UID
  Future<UserProfile?> getUserProfile(String uid);

  /// Real-time stream of user profile changes
  Stream<UserProfile?> userProfileStream(String uid);
}
