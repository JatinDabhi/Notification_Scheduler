const express = require("express");
const {
  triggerCronForCurrentTime,
  triggerCronForAllApps,
  executeJob,
  getCronStatus
} = require("../services/schedulerService");

const router = express.Router();

/**
 * GET /api/cron/status
 * View current IST time, all apps, their configured times, and pending count
 */
router.get("/status", async (req, res) => {
  try {
    const status = await getCronStatus();
    res.status(200).json({ success: true, data: status });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

/**
 * GET & POST /api/cron/trigger
 * Triggers notification:
 *  - ?appId=xxx -> triggers only for specific appId
 *  - ?all=true -> triggers FIFO for all apps immediately
 *  - no query params -> matches current IST time against app schedules
 */
const handleTrigger = async (req, res) => {
  try {
    const { appId, all, force } = { ...req.query, ...req.body };

    if (appId) {
      console.log(`⚡ Manual trigger requested for appId: ${appId}`);
      const result = await executeJob(appId);
      return res.status(200).json({
        success: true,
        mode: "single_app",
        appId,
        result
      });
    }

    if (all === "true" || force === "true") {
      console.log(`⚡ Force trigger all apps requested`);
      const results = await triggerCronForAllApps();
      return res.status(200).json({
        success: true,
        mode: "all_apps",
        results
      });
    }

    // Default: Check current IST time and trigger matching apps
    const cronResult = await triggerCronForCurrentTime();
    return res.status(200).json({
      success: true,
      mode: "scheduled_time_match",
      currentTimeIST: cronResult.time,
      results: cronResult.results
    });
  } catch (error) {
    console.error("❌ Cron trigger error:", error);
    res.status(500).json({ success: false, message: error.message });
  }
};

router.get("/trigger", handleTrigger);
router.post("/trigger", handleTrigger);

module.exports = router;
