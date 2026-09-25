const schedule = require("node-schedule");
const { getMessaging } = require('firebase-admin/messaging');
const { getFirebaseApp } = require('../config/firebase');
const { getTitleModel } = require("../models/titleModel");
const { getSettingsModel } = require("../models/SettingsModel");
const { getLogModel } = require("../models/LogModel");
const AppModel = require('../models/AppModel');

// Store active cron jobs so we can cancel/re-create them
let activeJobs = [];

/**
 * Sends a notification using Firebase Admin SDK
 */
const sendFirebaseNotification = async (appId, title, description, topic = "all") => {
  try {
    const app = await getFirebaseApp(appId);
    const messaging = getMessaging(app);

    const message = {
      notification: {
        title: title,
        body: description,
      },
      topic: topic,
      android: {
        priority: "high",
      },
    };

    const response = await messaging.send(message);
    console.log(`✅ [${appId}] Firebase notification sent successfully:`, response);
    return { success: true };
  } catch (error) {
    console.error(`❌ [${appId}] Error sending Firebase notification:`, error.message);
    return { success: false, error: error.message };
  }
};

/**
 * Execute the scheduled daily job action for a specific appId
 */
const executeJob = async (appId) => {
  console.log(`\n⏰ [${new Date().toISOString()}] ================= FIFO SCHEDULED TRIGGER [${appId}] =================`);
  const Log = getLogModel(appId);
  try {
    const Title = getTitleModel(appId);

    // Get the oldest queued title for this appId (FIFO)
    const item = await Title.findOne({ 
      status: { $in: ["queued", "immediate", "pending"] } 
    }).sort({ createdAt: 1 });

    if (!item) {
      console.log(`ℹ️ [${appId}] No queued notifications found. Nothing to send.`);
      await Log.create({
        appId, actionType: "schedule", status: "skipped", 
        reason: "No queued notifications found.", title: "N/A", description: "N/A"
      });
      return { success: false, reason: "No queued notifications found" };
    }

    console.log(`📌 Picked Title ID: ${item._id}`);
    console.log(`📌 Title: "${item.title}"`);
    console.log(`📌 Description: "${item.description}"`);

    // Send the notification
    const result = await sendFirebaseNotification(appId, item.title, item.description);

    if (result.success) {
      // Auto-delete item from MongoDB after sending
      await Title.findByIdAndDelete(item._id);
      await Log.create({
        appId, actionType: "schedule", status: "success", 
        reason: "Notification sent successfully.", title: item.title, description: item.description
      });
      console.log(`✅ [${appId}] Notification auto-deleted from MongoDB: ${item._id}`);
      return { success: true, sent: { title: item.title, description: item.description, id: item._id } };
    } else {
      await Log.create({
        appId, actionType: "schedule", status: "failed", 
        reason: result.error || "Unknown Firebase error", title: item.title, description: item.description
      });
      console.log(`❌ [${appId}] Failed to send, status not updated.`);
      return { success: false, error: result.error || "Unknown Firebase error" };
    }

  } catch (error) {
    console.error(`❌ [${appId}] Failed to execute scheduled task:`, error.message);
    await Log.create({
        appId, actionType: "schedule", status: "failed", 
        reason: "Internal Task Error: " + error.message, title: "N/A", description: "N/A"
    });
    return { success: false, error: error.message };
  } finally {
    console.log(`=================================================================\n`);
  }
};

const lastTriggeredMinute = {};

/**
 * Trigger cron for apps matching current time in Asia/Kolkata
 */
const triggerCronForCurrentTime = async () => {
  const now = new Date();
  const istTimeStr = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Kolkata',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }).format(now);

  console.log(`⏱️ Trigger Cron checking at IST time: ${istTimeStr}`);

  const apps = await AppModel.find({});
  const results = [];

  for (const appDoc of apps) {
    const appId = appDoc.appId;
    const Settings = getSettingsModel(appId);
    const settings = await Settings.findOne({ appId });

    if (settings && settings.notificationTimes && settings.notificationTimes.includes(istTimeStr)) {
      if (lastTriggeredMinute[appId] === istTimeStr) {
        results.push({ appId, triggered: false, reason: "Already triggered in this minute", time: istTimeStr });
        continue;
      }
      lastTriggeredMinute[appId] = istTimeStr;
      console.log(`🎯 Matched schedule for ${appId} at ${istTimeStr}! Executing job...`);
      const res = await executeJob(appId);
      results.push({ appId, triggered: true, time: istTimeStr, result: res });
    } else {
      results.push({ appId, triggered: false, time: istTimeStr, configuredTimes: settings?.notificationTimes || [] });
    }
  }

  return { time: istTimeStr, results };
};

/**
 * Trigger cron for all apps immediately
 */
const triggerCronForAllApps = async () => {
  const apps = await AppModel.find({});
  const results = [];

  for (const appDoc of apps) {
    const appId = appDoc.appId;
    const res = await executeJob(appId);
    results.push({ appId, result: res });
  }

  return results;
};

/**
 * Get cron status & scheduled times
 */
const getCronStatus = async () => {
  const now = new Date();
  const istTimeStr = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Kolkata',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).format(now);

  const apps = await AppModel.find({});
  const appStatuses = [];

  for (const appDoc of apps) {
    const appId = appDoc.appId;
    const Settings = getSettingsModel(appId);
    const Title = getTitleModel(appId);

    const settings = await Settings.findOne({ appId });
    const pendingCount = await Title.countDocuments({
      status: { $in: ["queued", "immediate", "pending"] }
    });

    appStatuses.push({
      appId,
      appName: appDoc.appName,
      notificationTimes: settings?.notificationTimes || [],
      pendingNotificationsCount: pendingCount
    });
  }

  return {
    currentTimeIST: istTimeStr,
    totalApps: apps.length,
    apps: appStatuses
  };
};

/**
 * Initialize scheduler on server startup or when settings change
 */
const initScheduler = async () => {
  try {
    // 1. Cancel all existing jobs
    activeJobs.forEach(job => job.cancel());
    activeJobs = [];

    let totalJobs = 0;
    let appsConfigured = 0;

    // 2. Discover all apps from MongoDB
    const apps = await AppModel.find({});
    
    for (const appDoc of apps) {
      const appId = appDoc.appId;
      
      // Fetch settings for this app
      const Settings = getSettingsModel(appId);
      const settings = await Settings.findOne({ appId });
      
      if (settings && settings.notificationTimes && settings.notificationTimes.length > 0) {
        appsConfigured++;
        
        settings.notificationTimes.forEach((timeStr) => {
          const [hour, minute] = timeStr.split(":");
          
          if (!hour || !minute) {
             console.log(`⚠️ [${appId}] Invalid time format: ${timeStr}. Expected HH:mm`);
             return;
          }

          const cronExpression = `${minute} ${hour} * * *`;
          console.log(`📅 [${appId}] Job scheduled for daily execution at ${timeStr} (Cron: ${cronExpression}, TZ: Asia/Kolkata)`);
          
          const job = schedule.scheduleJob({ rule: cronExpression, tz: 'Asia/Kolkata' }, async () => {
            await executeJob(appId);
          });

          if (job) {
             activeJobs.push(job);
             totalJobs++;
          }
        });
      }
    }

    console.log(`🔄 Scheduler Service Initialized: Scheduled ${totalJobs} jobs across ${appsConfigured} app(s).`);

  } catch (error) {
    console.error("❌ Failed to initialize scheduler service:", error.message);
  }
};

module.exports = {
  executeJob,
  initScheduler,
  sendFirebaseNotification,
  triggerCronForCurrentTime,
  triggerCronForAllApps,
  getCronStatus
};
