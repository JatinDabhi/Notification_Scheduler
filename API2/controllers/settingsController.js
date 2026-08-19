const { getSettingsModel } = require("../models/SettingsModel");
const { initScheduler } = require("../services/schedulerService");

exports.getSettings = async (req, res) => {
  try {
    const { appId } = req.query;
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in query parameters" });
    }

    const Settings = getSettingsModel(appId);

    let settings = await Settings.findOne({ appId });
    if (!settings) {
      settings = await Settings.create({ appId, notificationTimes: [] });
    }
    res.status(200).json({ success: true, data: settings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateNotificationTimes = async (req, res) => {
  try {
    const { appId, notificationTimes } = req.body;
    
    if (!appId) {
      return res.status(400).json({ success: false, message: "Please provide appId in body" });
    }

    if (!Array.isArray(notificationTimes)) {
      return res.status(400).json({ success: false, message: "notificationTimes must be an array of strings (e.g. ['10:00', '14:00'])" });
    }

    const Settings = getSettingsModel(appId);

    let settings = await Settings.findOne({ appId });
    if (!settings) {
      settings = await Settings.create({ appId, notificationTimes });
    } else {
      settings.notificationTimes = notificationTimes;
      await settings.save();
    }

    // Re-initialize the scheduler to apply the new times
    await initScheduler();

    res.status(200).json({ success: true, data: settings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
