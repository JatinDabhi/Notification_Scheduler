const mongoose = require('mongoose');
require('dotenv').config();
const { getTitleModel } = require('./models/titleModel');

mongoose.connect(process.env.MONGO_URI).then(async () => {
    const Title = getTitleModel('ramdevpir-wallpaper-e4e97');
    const items = await Title.find({ status: { $in: ["queued", "immediate", "pending"] } });
    console.log('Queued items:', items.length);
    console.log(items);
    process.exit(0);
});
