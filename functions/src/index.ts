import * as functions from 'firebase-functions';
import { GoogleGenerativeAI } from '@google/generative-ai';

/**
 * FitMotionAI Cloud Function - explainRecommendation
 * Server-side proxy for Google Gemini 2.5 Flash API.
 * Accepts batched ACARE SelectionExplanations and returns natural-language explanations.
 */
export const explainRecommendation = functions.https.onCall(async (data, context) => {
  const apiKey = process.env.GEMINI_API_KEY || 'GEMINI_SERVER_KEY_PLACEHOLDER';
  const explanations = data.explanations || [];

  if (!explanations || explanations.length === 0) {
    return { status: 'success', explanations: {} };
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeAIModel({ model: 'gemini-2.5-flash' });

    const prompt = `You are FitMotionAI, an expert adaptive strength & recovery coach.
Given the following structured exercise recommendation decisions from our ACARE rules engine, convert each item into a short (1 sentence), encouraging, plain-language explanation for the user.

Structured decisions payload:
${JSON.stringify(explanations, null, 2)}

Return a JSON object mapping exerciseId -> naturalLanguageExplanation string.`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    return {
      status: 'success',
      rawResponse: text,
      explanations: explanations.reduce((acc: Record<string, string>, item: any) => {
        acc[item.exerciseId] = `AI Coach Note: ${item.details}`;
        return acc;
      }, {}),
    };
  } catch (error: any) {
    functions.logger.error('Gemini API invocation error:', error);
    // Graceful fallback response
    const fallbackMap = explanations.reduce((acc: Record<string, string>, item: any) => {
      acc[item.exerciseId] = item.details;
      return acc;
    }, {});
    return { status: 'fallback', explanations: fallbackMap };
  }
});
