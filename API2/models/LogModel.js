const mongoose = require("mongoose");

const logSchema = new mongoose.Schema({
  appId: {
    type: String,
    required: true,
  },
  actionType: {
    type: String,
    enum: ["instant", "schedule"],
    required: true,
  },
  status: {
    type: String,
    enum: ["success", "failed", "skipped"],
    required: true,
  },
  title: {
    type: String,
  },
  description: {
    type: String,
  },
  reason: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 30 * 24 * 60 * 60 // Auto-delete logs after 30 days
  },
});

// Using dynamic collections for logs as well
const getLogModel = (appId) => {
  const collectionName = `logs_${appId}`;
  
  if (mongoose.models[collectionName]) {
    return mongoose.models[collectionName];
  }
  
  return mongoose.model(collectionName, logSchema, collectionName);
};

module.exports = { getLogModel };
