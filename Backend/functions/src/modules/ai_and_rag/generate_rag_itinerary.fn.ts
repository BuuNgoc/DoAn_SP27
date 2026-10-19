import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';

/**
 * [FE-05 & RAG] Callable: Personalized RAG Itinerary Planner
 * Nhận thông tin: timeAvailable, budget, interests, transportation -> Gợi ý lịch trình cá nhân hóa
 */
export const generateRagItinerary = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { availableHours, budgetVnd, interests, transportation } = data;

  // Mock RAG Generated Itinerary
  const itinerary = {
    title: `Lịch trình Ngũ Hành Sơn (${availableHours || 4} giờ)`,
    estimatedCost: budgetVnd || 200000,
    transportation: transportation || 'Xe máy / Đi bộ',
    stops: [
      {
        order: 1,
        destinationId: 'chua_tam_thai',
        name: 'Chùa Tam Thai & Thủy Sơn',
        durationMinutes: 90,
        activity: 'Thăm viếng chùa cổ và vãn cảnh đỉnh Thủy Sơn',
      },
      {
        order: 2,
        destinationId: 'lang_da_non_nuoc',
        name: 'Làng Đá Mỹ Nghệ Non Nước',
        durationMinutes: 60,
        activity: 'Xem nghệ nhân đục đẽo tượng đá và trải nghiệm làm quà lưu niệm',
      },
      {
        order: 3,
        destinationId: 'pho_an_thuong',
        name: 'Phố Du Lịch An Thượng',
        durationMinutes: 90,
        activity: 'Thưởng thức ẩm thực và cà phê giải khát',
      }
    ]
  };

  await db.collection('ai_itineraries_and_logs').add({
    userId: context.auth.uid,
    type: 'RAG_ITINERARY',
    inputParams: { availableHours, budgetVnd, interests, transportation },
    itinerary,
    createdAt: new Date(),
  });

  return itinerary;
});
