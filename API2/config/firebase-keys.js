const AppModel = require('../models/AppModel');
const { getFirebaseApp } = require('./firebase');

// Pre-configured App List. Keys are securely managed in MongoDB Atlas to avoid GitHub leaks.
const FIREBASE_APPS = [
  {
    appId: "dwarkadhish-wallpaper-9e560",
    appName: "Dwarkadhish Wallpaper",
  },
  {
    appId: "ramdevpir-wallpaper-e4e97",
    appName: "Ramdevpir Wallpaper",
  },
  {
    appId: "khatushyam-wallpaper-77315",
    appName: "Khatushyam Wallpaper",
  },
  {
    appId: "flatease-dc5bc",
    appName: "FlatEase",
  }
];

const syncAppsFromConfig = async () => {
  try {
    let syncedCount = 0;

    for (const app of FIREBASE_APPS) {
      const cleanAppId = app.appId.trim().toLowerCase();

      const existing = await AppModel.findOne({ appId: cleanAppId });
      if (!existing) {
        await AppModel.create({
          appId: cleanAppId,
          appName: app.appName,
          firebaseKeyJson: ""
        });
        console.log(`➕ Registered initial app in DB: ${cleanAppId}`);
      } else if (existing.appName !== app.appName) {
        existing.appName = app.appName;
        await existing.save();
      }

      // Try initializing Firebase App from DB
      try {
        const doc = existing || await AppModel.findOne({ appId: cleanAppId });
        if (doc && doc.firebaseKeyJson) {
          await getFirebaseApp(cleanAppId);
          syncedCount++;
        }
      } catch (e) {
        // App will be initialized once a valid key is set
      }
    }

    console.log(`🔄 Pre-configured Apps Synced: ${syncedCount} apps active with valid keys`);

  } catch (error) {
    console.error("❌ Failed to sync pre-configured apps:", error.message);
  }
};

module.exports = {
  FIREBASE_APPS,
  syncAppsFromConfig
};
