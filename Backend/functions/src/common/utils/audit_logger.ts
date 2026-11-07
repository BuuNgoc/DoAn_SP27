import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

export interface AuditLogEntry {
  actorUid: string;
  actorEmail?: string;
  actorRole: string;
  action: string;
  targetCollection: string;
  targetId?: string;
  details?: Record<string, any>;
  ipAddress?: string;
}

/**
 * Records administrative activity logs in Firestore [FE-28]
 */
export async function logAuditEvent(entry: AuditLogEntry): Promise<void> {
  try {
    await db.collection('system_administration').doc('audit_logs').collection('logs').add({
      ...entry,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Lỗi ghi Audit Log:', error);
  }
}
