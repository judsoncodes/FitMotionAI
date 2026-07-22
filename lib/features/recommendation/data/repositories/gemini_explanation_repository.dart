import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../workout/domain/models/workout_plan.dart';

abstract class GeminiExplanationRepository {
  /// Fetches natural-language Gemini explanations for a list of ACARE explanations
  Future<Map<String, String>> fetchNaturalLanguageExplanations(
    List<SelectionExplanation> explanations,
  );
}

class GeminiExplanationRepositoryImpl implements GeminiExplanationRepository {
  final FirebaseFunctions Function()? _functionsGetter;

  GeminiExplanationRepositoryImpl({FirebaseFunctions Function()? functionsGetter})
      : _functionsGetter = functionsGetter;

  @override
  Future<Map<String, String>> fetchNaturalLanguageExplanations(
    List<SelectionExplanation> explanations,
  ) async {
    if (explanations.isEmpty) return {};

    final fallbackMap = {
      for (final e in explanations) e.exerciseId: e.details,
    };

    try {
      final functions = _functionsGetter?.call() ?? FirebaseFunctions.instance;
      final callable = functions.httpsCallable('explainRecommendation');
      final payload = {
        'explanations': explanations.map((e) => e.toMap()).toList(),
      };

      final response = await callable.call(payload);
      final data = response.data as Map<String, dynamic>?;

      if (data != null && data['explanations'] != null) {
        final Map<String, dynamic> rawMap = Map<String, dynamic>.from(data['explanations']);
        return rawMap.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (e) {
      debugPrint('[GeminiExplanationRepository] Notice ($e). Using local structured ACARE explanations fallback.');
    }

    return fallbackMap;
  }
}
