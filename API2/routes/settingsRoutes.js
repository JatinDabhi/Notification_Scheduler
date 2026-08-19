const express = require("express");
const { getSettings, updateNotificationTimes } = require("../controllers/settingsController");

const router = express.Router();

router.route("/")
  .get(getSettings)
  .put(updateNotificationTimes);

module.exports = router;
