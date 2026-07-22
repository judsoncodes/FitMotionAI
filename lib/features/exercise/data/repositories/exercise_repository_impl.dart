import 'package:cloud_firestore/cloud_firestore.dart';

import '../exercise_seed_data.dart';
import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final FirebaseFirestore _firestore;
  List<Exercise>? _cachedLibrary;

  ExerciseRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Exercise>> getExerciseLibrary() async {
    if (_cachedLibrary != null && _cachedLibrary!.isNotEmpty) {
      return _cachedLibrary!;
    }

    try {
      final snapshot = await _firestore.collection('exercises').get();
      if (snapshot.docs.isNotEmpty) {
        _cachedLibrary = snapshot.docs.map((doc) {
          final data = doc.data();
          return Exercise.fromMap({...data, 'id': doc.id});
        }).toList();
        return _cachedLibrary!;
      }
    } catch (_) {}

    // Fallback to offline seed dataset
    _cachedLibrary = ExerciseSeedData.exercises;
    return _cachedLibrary!;
  }
}
