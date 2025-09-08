import { onDocumentCreated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";

admin.initializeApp();

export const addmessage = onDocumentCreated(
  "broadcasts/{broadcastId}",      // Firestore-Pfad    // Optionen
  async (event) => {                // Handler
    const data = event.data.data();

    const message = {
      topic: "test",
      notification: {
        title: data.title,
        body: data.summary,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Broadcast sent:", response);
      return response;
    } catch (error) {
      console.error("Error sending broadcast:", error);
      throw error;
    }
  }
);
