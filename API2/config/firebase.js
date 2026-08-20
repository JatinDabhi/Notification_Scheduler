const { initializeApp, cert, getApp, getApps, deleteApp } = require('firebase-admin/app');
const AppModel = require('../models/AppModel');

const getFirebaseApp = async (appId) => {
  try {
    const existingApp = getApps().find(app => app.name === appId);
    if (existingApp) {
      return existingApp;
    }

    const appDoc = await AppModel.findOne({ appId });
    
    if (!appDoc || !appDoc.firebaseKeyJson) {
      throw new Error(`Firebase service account key not found in DB for appId: ${appId}`);
    }

    const serviceAccount = JSON.parse(appDoc.firebaseKeyJson);
    
    const app = initializeApp({
      credential: cert(serviceAccount)
    }, appId);

    console.log(`✅ Firebase App initialized for appId: ${appId}`);
    return app;
  } catch (error) {
    console.error(`❌ Error initializing Firebase app for ${appId}:`, error.message);
    throw error;
  }
};

const reinitializeFirebaseApp = async (appId) => {
  try {
    const existingApp = getApps().find(app => app.name === appId);
    if (existingApp) {
      await deleteApp(existingApp);
      console.log(`🔄 Deleted existing Firebase App for appId: ${appId}`);
    }
    return await getFirebaseApp(appId);
  } catch (error) {
    console.error(`❌ Error reinitializing Firebase app for ${appId}:`, error.message);
    throw error;
  }
};

module.exports = { getFirebaseApp, reinitializeFirebaseApp };
