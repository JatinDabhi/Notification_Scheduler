const mongoose = require("mongoose");

const appSchema = new mongoose.Schema({
  appId: {
    type: String,
    required: true,
    unique: true,
  },
  appName: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("App", appSchema);
