const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const { getFirebaseApp, reinitializeFirebaseApp } = require('../config/firebase');
const AppModel = require('../models/AppModel');
const { initScheduler } = require('../services/schedulerService');

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
      await reinitializeFirebaseApp(cleanAppId);
    } catch (firebaseErr) {
      // If initialization fails, we might want to delete the invalid file
      if (fs.existsSync(keyPath)) fs.unlinkSync(keyPath);
      return res.status(500).json({
        success: false,
        message: "Failed to initialize Firebase app: " + firebaseErr.message,
      });
    }

    // 5. Save App in Database
    const finalAppName = appName || cleanAppId;
    await AppModel.findOneAndUpdate(
      { appId: cleanAppId },
      { appName: finalAppName },
      { upsert: true, new: true }
    );

    res.status(200).json({
      success: true,
      message: `App '${finalAppName}' registered successfully!`,
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

// @desc    Get all registered apps
// @route   GET /api/apps
// @access  Public
exports.getAllApps = async (req, res) => {
  try {
    const apps = await AppModel.find({}).sort({ createdAt: -1 });
    res.status(200).json({
      success: true,
      data: apps,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Delete a registered app
// @route   DELETE /api/apps/:appId
// @access  Public
exports.deleteApp = async (req, res) => {
  try {
    const { appId } = req.params;
    
    // Delete from DB
    const deletedApp = await AppModel.findOneAndDelete({ appId });
    if (!deletedApp) {
      return res.status(404).json({ success: false, message: "App not found" });
    }

    // Delete JSON file
    const keyPath = path.join(__dirname, '..', 'config', 'firebase_keys', `${appId}.json`);
    if (fs.existsSync(keyPath)) {
      fs.unlinkSync(keyPath);
    }

    // Drop dynamic collections associated with the app
    const cleanAppId = appId.trim().toLowerCase();
    const capitalizedAppId = cleanAppId.charAt(0).toUpperCase() + cleanAppId.slice(1);
    const collectionsToDrop = [`${capitalizedAppId} Notification`, `${capitalizedAppId} Schedule`, `${capitalizedAppId} Log`];
    for (const collectionName of collectionsToDrop) {
      try {
        await mongoose.connection.db.dropCollection(collectionName);
      } catch (err) {
        // Ignore if collection doesn't exist
      }
    }
    
    // Reload scheduler to cancel any cron jobs for the deleted app
    await initScheduler();

    res.status(200).json({
      success: true,
      message: "App deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
