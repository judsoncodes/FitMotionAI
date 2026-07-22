import '../models/exercise.dart';

abstract class ExerciseRepository {
  /// Fetch exercise library with in-memory caching
  Future<List<Exercise>> getExerciseLibrary();
}
