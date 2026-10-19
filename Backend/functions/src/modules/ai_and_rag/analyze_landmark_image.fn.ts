import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';

/**
 * [FE-05] Callable: Landmark Vision AI Recognition (Gemini Vision)
 * Du khách chụp ảnh hoặc tải ảnh lên để nhận diện địa danh Ngũ Hành Sơn.
 */
export const analyzeLandmarkImage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { imageBase64 } = data;
  if (!imageBase64) {
    throw new functions.https.HttpsError('invalid-argument', 'Thiếu dữ liệu hình ảnh.');
  }

  // TODO: Call Gemini Vision Model API with imageBase64 (LI-09)
  // Mock response for scaffolding
  const recognizedLandmark = {
    destinationId: 'dong_huyen_khong',
    destinationName: 'Động Huyền Không - Ngũ Hành Sơn',
    confidenceScore: 0.96,
    historicalContext: 'Động Huyền Không là hang động lộ thiên đẹp nhất trong quần thể Ngũ Hành Sơn...',
    suggestedActivities: ['Thắp hương Chùa Tam Thai', 'Khám phá Động Hoa Nghiêm', 'Check-in VR360'],
  };

  // Log recognition event to Firestore
  await db.collection('ai_itineraries_and_logs').add({
    userId: context.auth.uid,
    type: 'PHOTO_RECOGNITION',
    result: recognizedLandmark,
    createdAt: new Date(),
  });

  return recognizedLandmark;
});
