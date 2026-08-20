const mongoose = require("mongoose");

const settingsSchema = new mongoose.Schema(
  {
    appId: {
      type: String,
      required: true,
      unique: true, // It is a separate collection, but good for uniqueness anyway
      trim: true,
    },
    notificationTimes: {
      type: [String],
      default: [],
      // e.g., ["10:00", "14:30", "18:00"] (24-hour format)
    },
  },
  {
    timestamps: true,
    autoCreate: false, // Prevents creating empty collections on model load
  }
);

const models = {};

const getSettingsModel = (appId) => {
  const cleanAppId = appId.trim().toLowerCase();
  const capitalizedAppId = cleanAppId.charAt(0).toUpperCase() + cleanAppId.slice(1);
  const collectionName = `${capitalizedAppId} Schedule`;
  
  if (mongoose.models[collectionName]) {
    return mongoose.models[collectionName];
  }
  
  if (models[collectionName]) {
    return models[collectionName];
  }

  const model = mongoose.model(collectionName, settingsSchema, collectionName);
  models[collectionName] = model;
  return model;
};

module.exports = {
  settingsSchema,
  getSettingsModel
};
