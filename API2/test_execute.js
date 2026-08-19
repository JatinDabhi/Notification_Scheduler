const mongoose = require('mongoose');
require('dotenv').config();
const { executeJob } = require('./services/schedulerService');

mongoose.connect(process.env.MONGO_URI).then(async () => {
    await executeJob('ramdevpir-wallpaper-e4e97');
    console.log("Done");
    process.exit(0);
});
