const express = require("express");
const { registerApp } = require("../controllers/appController");

const router = express.Router();

router.post("/register", registerApp);

module.exports = router;
