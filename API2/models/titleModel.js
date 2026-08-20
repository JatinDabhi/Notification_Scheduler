const mongoose = require("mongoose");

const titleSchema = new mongoose.Schema(
  {
    appId: {
      type: String,
      required: [true, "App ID is required"],
      trim: true,
      index: true,
    },
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Description is required"],
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    scheduledAt: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ["pending", "executed", "failed", "immediate", "queued", "sent"],
      default: "queued",
    },
    callbackUrl: {
      type: String,
      trim: true,
      default: null,
    },
    executedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    autoCreate: false, // Prevents creating empty collections on model load
  }
);

// We store dynamic models so we don't compile them more than once.
const models = {};

const getTitleModel = (appId) => {
  const cleanAppId = appId.trim().toLowerCase();
  const capitalizedAppId = cleanAppId.charAt(0).toUpperCase() + cleanAppId.slice(1);
  const collectionName = `${capitalizedAppId} Notification`;
  
  if (mongoose.models[collectionName]) {
    return mongoose.models[collectionName];
  }
  
  if (models[collectionName]) {
    return models[collectionName];
  }

  const model = mongoose.model(collectionName, titleSchema, collectionName);
  models[collectionName] = model;
  return model;
};

module.exports = {
  titleSchema,
  getTitleModel
};
