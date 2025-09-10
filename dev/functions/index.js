import { onDocumentCreated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";
import { onTaskDispatched } from "firebase-functions/tasks";
import { GoogleAuth } from "google-auth-library";
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getFunctions } from "firebase-admin/functions";

admin.initializeApp();

export const addmessage = onDocumentCreated(
  "broadcasts/{broadcastId}",
  async (event) => {
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




// this function has the taskQueue with all the tasks
export const sendPrayerNotification = onTaskDispatched(
  async (req) => {
    const { prayerName } = req.body || req.data; // retrieves the data coming with every task

    // creating necessary information for prayer
    const message = {
      topic: prayerName,
      notification: {
        title: "Gebetszeit",
        body: `Es ist Zeit für ${prayerName}`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prayerName}:`, err);
    }
  }
);


let auth;


async function getFunctionUrl(name, location="us-central1") {
  if (!auth) {
    auth = new GoogleAuth({
      scopes: "https://www.googleapis.com/auth/cloud-platform",
    });
  }
  const projectId = await auth.getProjectId();
  const url = "https://cloudfunctions.googleapis.com/v2beta/" +
    `projects/${projectId}/locations/${location}/functions/${name}`;

  const client = await auth.getClient();
  const res = await client.request({url});
  const uri = res.data?.serviceConfig?.uri;
  if (!uri) {
    throw new Error(`Unable to retreive uri for function at ${url}`);
  }
  return uri;
}

// will be triggered every day at night 
// and appends for all prayers a task to the queue
// The queue will execute all the tasks when their time arrives
export const scheduleDailyPrayers = onSchedule(
  {
    schedule: "every day 00:00",
    timeZone: "Europe/Berlin",
  },
  async () => {
    console.log("Berechne Gebetszeiten für heute...");
    
    // for testing purposes: static 
    const prayerTimes = {
      fajr: "05:15",
      dhuhr: "13:10",
      asr: "17:00",
      maghrib: "20:15",
      isha: "22:00",
    };

    // seperating date from time, and only take the date
    // the time will be appended as soon as we get it from the prayer times
    const today = new Date().toISOString().split("T")[0];
    const queue = getFunctions().taskQueue("prayer-queue");// queue in order to append tasks to the queue
    const targetUri = await getFunctionUrl("sendPrayerNotification"); //  gives as back the url to the function, which will finally trigger the notification

    for (const [prayer, time] of Object.entries(prayerTimes)) {
      const [hour, minute] = time.split(":").map(Number);
      const sendTime = new Date(today);
      sendTime.setHours(hour, minute, 0, 0);

      await queue.enqueue(
        { prayerName: prayer },
        {
          uri: targetUri,
          scheduleTime: sendTime.toISOString(), 
        }
      );

      console.log(`Task für ${prayer} geplant um ${sendTime.toISOString()}`);
    }
  }
);