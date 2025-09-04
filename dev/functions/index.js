const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendBroadcast = functions.firestore
  .document("broadcasts/{broadcastId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();

    const payload = {
      notification: {
        title: data.title,
        body: data.summary,
      },
      android: {
        priority: "high",
      },
    };

    // Send to everyone subscribed to "all"
    return admin.messaging().sendToTopic("all", payload);
  });
