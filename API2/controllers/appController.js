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

    // 2. Save App in Database first
    const finalAppName = appName || cleanAppId;
    await AppModel.findOneAndUpdate(
      { appId: cleanAppId },
      { 
        appName: finalAppName,
        firebaseKeyJson: typeof firebaseKeyJson === 'string' ? firebaseKeyJson : JSON.stringify(firebaseKeyJson)
      },
      { upsert: true, new: true }
    );

    // 3. Initialize Firebase App and verify token with Google OAuth2
    try {
      const testApp = await reinitializeFirebaseApp(cleanAppId);
      await testApp.options.credential.getAccessToken();
    } catch (firebaseErr) {
      // If initialization or token validation fails, delete the invalid DB record
      await AppModel.findOneAndDelete({ appId: cleanAppId });
      return res.status(400).json({
        success: false,
        message: "Firebase key validation failed: " + firebaseErr.message + ". Make sure the key has not been revoked.",
      });
    }

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
