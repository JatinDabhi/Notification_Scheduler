const schedule = require("node-schedule");
const fs = require('fs');
const path = require('path');
const { getMessaging } = require('firebase-admin/messaging');
const { getFirebaseApp } = require('../config/firebase');
const { getTitleModel } = require("../models/titleModel");
const { getSettingsModel } = require("../models/SettingsModel");

// Store active cron jobs so we can cancel/re-create them
let activeJobs = [];

/**
 * Sends a notification using Firebase Admin SDK
 */
const sendFirebaseNotification = async (appId, title, description, topic = "all") => {
  try {
    const app = getFirebaseApp(appId);
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
    return true;
  } catch (error) {
    console.error(`❌ [${appId}] Error sending Firebase notification:`, error.message);
    return false;
  }
};

/**
 * Execute the scheduled daily job action for a specific appId
 */
const executeJob = async (appId) => {
  console.log(`\n⏰ [${new Date().toISOString()}] ================= FIFO SCHEDULED TRIGGER [${appId}] =================`);
  try {
    const Title = getTitleModel(appId);

    // Get the oldest queued title for this appId (FIFO)
    const item = await Title.findOne({ 
      status: { $in: ["queued", "immediate", "pending"] } 
    }).sort({ createdAt: 1 });

    if (!item) {
      console.log(`ℹ️ [${appId}] No queued notifications found. Nothing to send.`);
      return;
    }

    console.log(`📌 Picked Title ID: ${item._id}`);
    console.log(`📌 Title: "${item.title}"`);
    console.log(`📌 Description: "${item.description}"`);

    // Send the notification
    const success = await sendFirebaseNotification(appId, item.title, item.description);

    if (success) {
      // Auto-delete item from MongoDB after sending
      await Title.findByIdAndDelete(item._id);
      console.log(`✅ [${appId}] Notification auto-deleted from MongoDB: ${item._id}`);
    } else {
      console.log(`❌ [${appId}] Failed to send, status not updated.`);
    }

  } catch (error) {
    console.error(`❌ [${appId}] Failed to execute scheduled task:`, error.message);
  }
  console.log(`=================================================================\n`);
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

    // 2. Discover all apps from firebase_keys directory
    const keysDir = path.join(__dirname, '..', 'config', 'firebase_keys');
    if (fs.existsSync(keysDir)) {
      const files = fs.readdirSync(keysDir);
      for (const file of files) {
        if (file.endsWith('.json')) {
          const appId = file.replace('.json', '');
          
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
              console.log(`📅 [${appId}] Job scheduled for daily execution at ${timeStr} (Cron: ${cronExpression})`);
              
              const job = schedule.scheduleJob(cronExpression, async () => {
                await executeJob(appId);
              });

              if (job) {
                 activeJobs.push(job);
                 totalJobs++;
              }
            });
          }
        }
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
};
