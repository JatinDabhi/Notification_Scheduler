const express = require("express");
const cors = require("cors");
require("dotenv").config();
require("./config/firebase"); // Initialize Firebase Admin

const connectDB = require("./config/db");
const titleRoutes = require("./routes/titleRoutes");
const settingsRoutes = require("./routes/settingsRoutes");
const cronRoutes = require("./routes/cronRoutes");
const { initScheduler } = require("./services/schedulerService");
const { syncAppsFromConfig } = require("./config/firebase-keys");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Lazy sync check for serverless environments
let hasSynced = false;
const ensureSetup = async () => {
  await connectDB();
  if (!hasSynced) {
    await syncAppsFromConfig();
    hasSynced = true;
  }
};

// Middleware to ensure DB is connected before handling any API request
app.use(async (req, res, next) => {
  try {
    await ensureSetup();
    next();
  } catch (err) {
    console.error("Database connection middleware error:", err.message);
    res.status(500).json({
      success: false,
      message: "Database connection failed",
      error: err.message,
    });
  }
});

// Root Health Endpoint
app.get("/", (req, res) => {
  res.status(200).json({
    status: "online",
    message: "Title & Description Storage API is running",
    deployedAt: "Vercel / Cloud Ready",
    endpoints: {
      apps: "/api/apps",
      titles: "/api/titles?appId=...",
      settings: "/api/settings?appId=...",
      logs: "/api/logs?appId=...",
      cronStatus: "/api/cron/status",
      cronTrigger: "/api/cron/trigger"
    }
  });
});

// API Routes
app.use("/api/titles", titleRoutes);
app.use("/api/settings", settingsRoutes);
app.use("/api/apps", require("./routes/appRoutes"));
app.use("/api/logs", require("./routes/logRoutes"));
app.use("/api/cron", cronRoutes);

// Scheduled trigger callback endpoint
app.post("/title-triggered", (req, res) => {
  console.log("Received scheduled title callback:", req.body);

  res.status(200).json({
    success: true,
    message: "Title trigger received",
    data: req.body,
  });
});

// 404 Route Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Resource not found",
  });
});

// Standalone server mode (when running locally or on VPS)
if (!process.env.VERCEL) {
  connectDB().then(async () => {
    await syncAppsFromConfig();
    initScheduler();
  });

  const PORT = process.env.PORT || 8080;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;
