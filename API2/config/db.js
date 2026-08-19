const mongoose = require("mongoose");
const dns = require("dns");

// Set public DNS servers to resolve MongoDB SRV records on Windows local networks
try {
  dns.setDefaultResultOrder("ipv4first");
  dns.setServers(["8.8.8.8", "8.8.4.4", "1.1.1.1"]);
} catch (err) {
  // Ignore DNS override errors if restricted
}

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || process.env.MONGO_URL || "mongodb://localhost:27017/title_db";
    
    if (mongoUri.includes("<db_password>")) {
      console.warn("⚠️ WARNING: Please replace '<db_password>' in your .env file with your actual MongoDB Atlas database password!");
    }

    const conn = await mongoose.connect(mongoUri);
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ MongoDB Connection Error: ${error.message}`);
    if (error.message.includes("querySrv") || error.message.includes("ECONNREFUSED")) {
      console.error("💡 Tip: Check your network/DNS connection or replace '<db_password>' with your actual password in .env. Also ensure your IP address is whitelisted in MongoDB Atlas (Network Access -> Allow Access From Anywhere).");
    }
  }
};

module.exports = connectDB;
