const express = require("express");
const { registerApp, getAllApps, deleteApp } = require("../controllers/appController");

const router = express.Router();

router.get("/", getAllApps);

module.exports = router;
