/**
 * Gemini AI & Vertex AI Config for SmartTravel (LI-09)
 * Used for Landmark Photo Recognition (FE-05) and RAG Itinerary Assistant
 */
export const GEMINI_CONFIG = {
  apiKey: process.env.GEMINI_API_KEY || 'AIzaSyStubGeminiApiKey12345',
  visionModel: 'gemini-1.5-flash',
  ragModel: 'gemini-1.5-pro',
  embeddingModel: 'text-embedding-004',
};
