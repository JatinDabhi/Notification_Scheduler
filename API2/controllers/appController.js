const fs = require('fs');
const path = require('path');
const { getFirebaseApp } = require('../config/firebase');

// @desc    Register a completely new app dynamically
// @route   POST /api/apps/register
// @access  Public
exports.registerApp = async (req, res) => {
  try {
    const { appId, appName, firebaseKeyJson } = req.body;

    if (!appId || !firebaseKeyJson) {
      return res.status(400).json({
        success: false,
        message: "appId and firebaseKeyJson are required",
      });
    }

    const cleanAppId = appId.trim().toLowerCase();

    // 1. Validate JSON
    let parsedJson;
    try {
      parsedJson = typeof firebaseKeyJson === 'string' ? JSON.parse(firebaseKeyJson) : firebaseKeyJson;
      if (!parsedJson.project_id) {
        throw new Error("Invalid Firebase Service Account Key (missing project_id)");
      }
    } catch (e) {
      return res.status(400).json({
        success: false,
        message: "Invalid Firebase JSON format: " + e.message,
      });
    }

    // 2. Ensure firebase_keys folder exists
    const keysDir = path.join(__dirname, '..', 'config', 'firebase_keys');
    if (!fs.existsSync(keysDir)) {
      fs.mkdirSync(keysDir, { recursive: true });
    }

    // 3. Write JSON file
    const keyPath = path.join(keysDir, `${cleanAppId}.json`);
    fs.writeFileSync(keyPath, JSON.stringify(parsedJson, null, 2));

    // 4. Initialize Firebase App immediately to verify it works
    try {
      getFirebaseApp(cleanAppId);
    } catch (firebaseErr) {
      // If initialization fails, we might want to delete the invalid file
      if (fs.existsSync(keyPath)) fs.unlinkSync(keyPath);
      return res.status(500).json({
        success: false,
        message: "Failed to initialize Firebase app: " + firebaseErr.message,
      });
    }

    res.status(200).json({
      success: true,
      message: `App '${appName || cleanAppId}' registered successfully!`,
      appId: cleanAppId,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
