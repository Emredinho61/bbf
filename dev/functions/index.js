import { onDocumentCreated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";
import { onTaskDispatched } from "firebase-functions/tasks";
import { GoogleAuth } from "google-auth-library";
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getFunctions } from "firebase-admin/functions";
import moment from 'moment-timezone';
import fs from "fs";
import path from "path";
import csv from "csv-parser";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

admin.initializeApp();

export async function getTodaysPrayerTimes() {
  const filePath = path.join(process.cwd(), "assets", "prayer_times.csv");
  return new Promise((resolve, reject) => {
    const results = [];
    fs.createReadStream(filePath)
      .pipe(csv({ separator: ";" }))
      .on("data", (data) => results.push(data))
      .on("end", () => {
        const todayStr = new Date().toLocaleDateString("de-DE", {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
          timeZone: "Europe/Berlin",
        });

        const todayRow = results.find((row) => row.Date === todayStr);

        if (todayRow) {
          const { Date, ...times } = todayRow;
          resolve(times);
        } else {
          resolve({});
        }
      })
      .on("error", reject);
  });
}

function subtractMinutes(timeStr, minutesToSubtract) {
  const [hours, minutes] = timeStr.split(":").map(Number);
  const date = new Date();
  date.setHours(hours, minutes, 0, 0);
  date.setMinutes(date.getMinutes() - minutesToSubtract);

  const hh = String(date.getHours()).padStart(2, "0");
  const mm = String(date.getMinutes()).padStart(2, "0");
  return `${hh}:${mm}`;
}


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
    let displayName = prayerName;
    if (displayName == 'Sunrise') {
      displayName = 'Shuruq';
    }
    // creating necessary information for prayer
    const message = {
      topic: prayerName,
      notification: {
        title: "Gebetszeit",
        body: `Es ist Zeit für ${displayName}`,
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

export const sendPrePrayerNotification5 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr5':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise5':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur5':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr5':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib5':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha5':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 5 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

export const sendPrePrayerNotification10 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr10':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise10':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur10':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr10':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib10':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha10':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 10 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

export const sendPrePrayerNotification15 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr15':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise15':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur15':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr15':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib15':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha15':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 15 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

export const sendPrePrayerNotification20 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr20':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise20':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur20':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr20':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib20':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha20':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 20 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

export const sendPrePrayerNotification30 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr30':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise30':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur30':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr30':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib30':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha30':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 30 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

export const sendPrePrayerNotification45 = onTaskDispatched(
  async (req) => {
    const { prayerName: prePrayerName } = req.body || req.data; // retrieves the data coming with every task
    let actualPrayerName = '';
    switch (prePrayerName) {
      case 'Fajr45':
        actualPrayerName = 'Fajr';
        break;
      case 'Sunrise45':
        actualPrayerName = 'Shuruq';
        break;
      case 'Dhur45':
        actualPrayerName = 'Dhur';
        break;
      case 'Asr45':
        actualPrayerName = 'Asr';
        break;
      case 'Maghrib45':
        actualPrayerName = 'Maghrib';
        break;
      case 'Isha45':
        actualPrayerName = 'Isha';
        break;

      default:
        break;
    }
    // creating necessary information for prayer
    const message = {
      topic: prePrayerName,
      notification: {
        title: "Erinnerung",
        body: `Bis zu ${actualPrayerName} sind noch 45 Minuten.`,
      },
      android: { priority: "high" },
      apns: { payload: { aps: { sound: "default" } } },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log(`Nachricht für ${prePrayerName} gesendet:`, response);
    } catch (err) {
      console.error(`Fehler beim Senden für ${prePrayerName}:`, err);
    }
  }
);

let auth;


async function getFunctionUrl(name, location = "us-central1") {
  if (!auth) {
    auth = new GoogleAuth({
      scopes: "https://www.googleapis.com/auth/cloud-platform",
    });
  }
  const projectId = await auth.getProjectId();
  const url = "https://cloudfunctions.googleapis.com/v2beta/" +
    `projects/${projectId}/locations/${location}/functions/${name}`;

  const client = await auth.getClient();
  const res = await client.request({ url });
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

    const prayerTimes = await getTodaysPrayerTimes();

    const prePrayerTimes5 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}5`, subtractMinutes(value, 5)])
    );

    const prePrayerTimes10 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}10`, subtractMinutes(value, 10)])
    );

    const prePrayerTimes15 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}15`, subtractMinutes(value, 15)])
    );

    const prePrayerTimes20 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}20`, subtractMinutes(value, 20)])
    );

    const prePrayerTimes30 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}30`, subtractMinutes(value, 30)])
    );

    const prePrayerTimes45 = Object.fromEntries(
      Object.entries(prayerTimes).map(([key, value]) => [`${key}45`, subtractMinutes(value, 45)])
    );

    const today = moment().tz("Europe/Berlin").format("YYYY-MM-DD");
    const prayerQueue = getFunctions().taskQueue("sendPrayerNotification");// queue in order to append tasks to the queue
    const prePrayerQueue5 = getFunctions().taskQueue("sendPrePrayerNotification5");
    const prePrayerQueue10 = getFunctions().taskQueue("sendPrePrayerNotification10");
    const prePrayerQueue15 = getFunctions().taskQueue("sendPrePrayerNotification15");
    const prePrayerQueue20 = getFunctions().taskQueue("sendPrePrayerNotification20");
    const prePrayerQueue30 = getFunctions().taskQueue("sendPrePrayerNotification30");
    const prePrayerQueue45 = getFunctions().taskQueue("sendPrePrayerNotification45");
    const targetUriPrayerTimes = await getFunctionUrl("sendPrayerNotification"); //  gives as back the url to the function, which will finally trigger the notification
    const targetUriPrePrayerTimes5 = await getFunctionUrl("sendPrePrayerNotification5");
    const targetUriPrePrayerTimes10 = await getFunctionUrl("sendPrePrayerNotification10");
    const targetUriPrePrayerTimes15 = await getFunctionUrl("sendPrePrayerNotification15");
    const targetUriPrePrayerTimes20 = await getFunctionUrl("sendPrePrayerNotification20");
    const targetUriPrePrayerTimes30 = await getFunctionUrl("sendPrePrayerNotification30");
    const targetUriPrePrayerTimes45 = await getFunctionUrl("sendPrePrayerNotification45");

    for (const [prayer, time] of Object.entries(prayerTimes)) {
      const sendTime = moment.tz(`${today} ${time}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prayerQueue.enqueue(
        { prayerName: prayer },
        {
          uri: targetUriPrayerTimes,
          scheduleTime: sendTime,
        }
      );

      console.log(`Task für ${prayer} geplant um ${sendTime}`);
    }
    for (const [prePrayer5, preTime5] of Object.entries(prePrayerTimes5)) {

      const sendPreTime5 = moment.tz(`${today} ${preTime5}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue5.enqueue(
        { prayerName: prePrayer5 },
        {
          uri: targetUriPrePrayerTimes5,
          scheduleTime: sendPreTime5,
        }
      );
      console.log(`Task für ${prePrayer5} geplant um ${sendPreTime5.toISOString()}`);
    }

    for (const [prePrayer10, preTime10] of Object.entries(prePrayerTimes10)) {

      const sendPreTime10 = moment.tz(`${today} ${preTime10}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue10.enqueue(
        { prayerName: prePrayer10 },
        {
          uri: targetUriPrePrayerTimes10,
          scheduleTime: sendPreTime10,
        }
      );
      console.log(`Task für ${prePrayer10} geplant um ${sendPreTime10.toISOString()}`);
    }

    for (const [prePrayer15, preTime15] of Object.entries(prePrayerTimes15)) {

      const sendPreTime15 = moment.tz(`${today} ${preTime15}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue15.enqueue(
        { prayerName: prePrayer15 },
        {
          uri: targetUriPrePrayerTimes15,
          scheduleTime: sendPreTime15,
        }
      );
      console.log(`Task für ${prePrayer15} geplant um ${sendPreTime15.toISOString()}`);
    }

    for (const [prePrayer20, preTime20] of Object.entries(prePrayerTimes20)) {

      const sendPreTime20 = moment.tz(`${today} ${preTime20}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue20.enqueue(
        { prayerName: prePrayer20 },
        {
          uri: targetUriPrePrayerTimes20,
          scheduleTime: sendPreTime20,
        }
      );
      console.log(`Task für ${prePrayer20} geplant um ${sendPreTime20.toISOString()}`);
    }

    for (const [prePrayer30, preTime30] of Object.entries(prePrayerTimes30)) {

      const sendPreTime30 = moment.tz(`${today} ${preTime30}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue30.enqueue(
        { prayerName: prePrayer30 },
        {
          uri: targetUriPrePrayerTimes30,
          scheduleTime: sendPreTime30,
        }
      );
      console.log(`Task für ${prePrayer30} geplant um ${sendPreTime30.toISOString()}`);
    }

    for (const [prePrayer45, preTime45] of Object.entries(prePrayerTimes45)) {

      const sendPreTime45 = moment.tz(`${today} ${preTime45}`, "YYYY-MM-DD HH:mm", "Europe/Berlin").toDate();

      await prePrayerQueue45.enqueue(
        { prayerName: prePrayer45 },
        {
          uri: targetUriPrePrayerTimes45,
          scheduleTime: sendPreTime45,
        }
      );
      console.log(`Task für ${prePrayer45} geplant um ${sendPreTime45.toISOString()}`);
    }

  }
);