const { initializeApp, cert, getApp, getApps } = require('firebase-admin/app');
const path = require('path');
const fs = require('fs');

const getFirebaseApp = (appId) => {
  try {
    // If already initialized, return it
    const existingApp = getApps().find(app => app.name === appId);
    if (existingApp) {
      return existingApp;
    }

    // Otherwise, initialize it from config/firebase_keys/
    const keyPath = path.join(__dirname, 'firebase_keys', `${appId}.json`);
    
    if (!fs.existsSync(keyPath)) {
      throw new Error(`Firebase service account key not found for appId: ${appId} at ${keyPath}`);
    }

    const serviceAccount = require(keyPath);
    
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

module.exports = { getFirebaseApp };
