import * as CryptoJS from 'crypto-js';

const QR_SECRET_KEY = process.env.QR_SECRET_KEY || 'SmartTravel_NguHanhSon_QR_SecretKey_2027';

/**
 * Anti-Fraud QR Check-in Cryptographic Signature Helper (LI-08)
 */
export function generateQrSignature(pointId: string, timestamp: number): string {
  const payload = `${pointId}_${timestamp}`;
  return CryptoJS.HmacSHA256(payload, QR_SECRET_KEY).toString(CryptoJS.enc.Hex);
}

export function verifyQrSignature(pointId: string, timestamp: number, signature: string): boolean {
  const expected = generateQrSignature(pointId, timestamp);
  return expected === signature;
}
