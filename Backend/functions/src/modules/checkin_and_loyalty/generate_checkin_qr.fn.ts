import * as functions from 'firebase-functions';
import { assertHasRole } from '../../common/middlewares/role_guard';
import { generateQrSignature } from '../../common/utils/qr_crypto';

/**
 * [FE-20] Tourism Manager Callable: Generate Signed Dynamic QR Payload
 */
export const generateCheckinQr = functions.https.onCall(async (data, context) => {
  await assertHasRole(context, ['TOURISM_MANAGER', 'ADMIN']);

  const { pointId } = data;
  if (!pointId) {
    throw new functions.https.HttpsError('invalid-argument', 'Thiếu pointId.');
  }

  const timestamp = Date.now();
  const signature = generateQrSignature(pointId, timestamp);

  return {
    pointId,
    timestamp,
    signature,
    qrPayload: JSON.stringify({ pointId, timestamp, signature }),
  };
});
