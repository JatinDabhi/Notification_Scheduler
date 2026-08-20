const express = require("express");
const cors = require("cors");
require("dotenv").config();
require("./config/firebase"); // Initialize Firebase Admin

const connectDB = require("./config/db");
const titleRoutes = require("./routes/titleRoutes");
const settingsRoutes = require("./routes/settingsRoutes");
const { initScheduler } = require("./services/schedulerService");

const app = express();

// Connect to MongoDB Database and initialize background job scheduler
connectDB().then(() => {
  initScheduler();
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Root Health Endpoint
app.get("/", (req, res) => {
  res.status(200).json({
    status: "online",
    message: "Title & Description Storage API is running",
  });
});

// API Routes
app.use("/api/titles", titleRoutes);
app.use("/api/settings", settingsRoutes);
app.use("/api/apps", require("./routes/appRoutes"));
app.use("/api/logs", require("./routes/logRoutes"));

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

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
