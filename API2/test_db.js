const mongoose = require('mongoose');
require('dotenv').config();
const { getSettingsModel } = require('./models/SettingsModel');

mongoose.connect(process.env.MONGO_URI).then(async () => {
    const Settings = getSettingsModel('ramdevpir-wallpaper-e4e97');
    const settings = await Settings.findOne({ appId: 'ramdevpir-wallpaper-e4e97' });
    console.log(settings);
    process.exit(0);
});
