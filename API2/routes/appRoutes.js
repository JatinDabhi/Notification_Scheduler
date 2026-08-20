const express = require("express");
const { registerApp, getAllApps, deleteApp } = require("../controllers/appController");

const router = express.Router();

router.get("/", getAllApps);
router.post("/register", registerApp);
router.delete("/:appId", deleteApp);

module.exports = router;
