const mongoose = require("mongoose");
const fs = require("fs");
const { initializeApp, cert, deleteApp } = require("firebase-admin/app");
require("dotenv").config();
const AppModel = require("./models/AppModel");

/**
 * Test if a service account object can fetch a valid Google OAuth2 access token
 */
async function testServiceAccountKey(parsedKey, testAppId = "temp-test-app") {
  let app;
  try {
    app = initializeApp({
      credential: cert(parsedKey)
    }, `${testAppId}-${Date.now()}`);

    const token = await app.options.credential.getAccessToken();
    await deleteApp(app);
    return { valid: true, token };
  } catch (error) {
    if (app) {
      try { await deleteApp(app); } catch (_) {}
    }
    return { valid: false, error: error.message };
  }
}

async function listAndTestAllApps() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log("========================================================");
  console.log(" 🔍 Testing Firebase Credentials For All Registered Apps ");
  console.log("========================================================\n");

  const apps = await AppModel.find({}).sort({ createdAt: -1 });
  if (apps.length === 0) {
    console.log("No apps found in MongoDB.");
    process.exit(0);
  }

  for (const app of apps) {
    process.stdout.write(`📱 [${app.appId}] (${app.appName})... `);
    if (!app.firebaseKeyJson) {
      console.log("❌ NO KEY FOUND in database!");
      continue;
    }

    try {
      const parsed = JSON.parse(app.firebaseKeyJson);
      const result = await testServiceAccountKey(parsed, app.appId);
      if (result.valid) {
        console.log(`✅ WORKING! (OAuth2 token verified)`);
      } else {
        console.log(`❌ INVALID: ${result.error}`);
      }
    } catch (e) {
      console.log(`❌ CORRUPT JSON: ${e.message}`);
    }
  }

  console.log("\n--------------------------------------------------------");
  console.log("To update an invalid key, run:");
  console.log("  node update_app_key.js <appId> <path-to-serviceAccountKey.json>");
  console.log("--------------------------------------------------------\n");
  process.exit(0);
}

async function updateKey() {
  const appId = process.argv[2];
  const keyFilePath = process.argv[3];

  if (!appId || !keyFilePath) {
    if (appId === "--status" || appId === "-s" || !appId) {
      await listAndTestAllApps();
      return;
    }
    console.log("Usage: node update_app_key.js <appId> <path-to-serviceAccountKey.json>");
    console.log("Example: node update_app_key.js ramdevpir-wallpaper-e4e97 ./ramdevpir.json");
    console.log("Or check status: node update_app_key.js");
    process.exit(1);
  }

  if (!fs.existsSync(keyFilePath)) {
    console.error(`❌ File not found: ${keyFilePath}`);
    process.exit(1);
  }

  let parsed;
  try {
    const raw = fs.readFileSync(keyFilePath, "utf8");
    parsed = JSON.parse(raw);
  } catch (err) {
    console.error(`❌ Error parsing JSON file: ${err.message}`);
    process.exit(1);
  }

  if (!parsed.project_id || !parsed.private_key) {
    console.error("❌ Invalid Firebase service account JSON! Must contain 'project_id' and 'private_key'.");
    process.exit(1);
  }

  const cleanAppId = appId.trim().toLowerCase();
  console.log(`\n⏳ Validating Firebase key with Google OAuth2 for project: ${parsed.project_id}...`);

  const testResult = await testServiceAccountKey(parsed, cleanAppId);
  if (!testResult.valid) {
    console.error(`\n❌ KEY VALIDATION FAILED: ${testResult.error}`);
    console.error("⚠️ This key cannot be used because Google OAuth2 rejected it.");
    console.error("👉 Please download a FRESH service account key from Firebase Console:");
    console.error(`   https://console.firebase.google.com/project/${parsed.project_id}/settings/serviceaccounts/adminsdk`);
    process.exit(1);
  }

  console.log("✅ Google OAuth2 Token verified successfully!");

  await mongoose.connect(process.env.MONGO_URI);
  console.log("✅ Connected to MongoDB Atlas!");

  const updated = await AppModel.findOneAndUpdate(
    { appId: cleanAppId },
    { firebaseKeyJson: JSON.stringify(parsed) },
    { new: true }
  );

  if (!updated) {
    console.warn(`⚠️ App '${cleanAppId}' was not found in DB. Creating new record...`);
    const newApp = await AppModel.create({
      appId: cleanAppId,
      appName: parsed.project_id,
      firebaseKeyJson: JSON.stringify(parsed),
    });
    console.log(`🎉 Successfully registered new app: ${newApp.appName} (${newApp.appId})`);
  } else {
    console.log(`🎉 Successfully updated Firebase key for: ${updated.appName} (${updated.appId}) in MongoDB Atlas!`);
  }

  console.log("\n🚀 You can now trigger notifications from the Admin App without any error!\n");
  process.exit(0);
}

updateKey().catch(err => {
  console.error("Error:", err.message);
  process.exit(1);
});
