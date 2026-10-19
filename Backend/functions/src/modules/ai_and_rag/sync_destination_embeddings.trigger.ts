import * as functions from 'firebase-functions';

/**
 * [FE-05 & RAG] Firestore Trigger: Generates and syncs vector embeddings
 * Triggers when a destination's details or cultural info are updated.
 */
export const syncDestinationEmbeddings = functions.firestore
  .document('destinations/{destinationId}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) return; // Deleted

    const data = change.after.data();
    if (!data) return;

    // Check if description changed
    const beforeData = change.before.data();
    const content = `${data.name?.vi || ''} ${data.overview?.vi || ''} ${data.culturalHistoricalInfo?.vi || ''}`;

    if (beforeData && beforeData.overview?.vi === data.overview?.vi) {
      return; // No need to recompute embedding
    }

    console.log(`Syncing vector embeddings for destination: ${context.params.destinationId}`);
    // TODO: Call Gemini Text Embedding model text-embedding-004 and update doc.embedding
  });
