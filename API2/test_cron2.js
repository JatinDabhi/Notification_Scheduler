const schedule = require('node-schedule');
const job = schedule.scheduleJob({ rule: '03 15 * * *', tz: 'Asia/Kolkata' }, () => {
    console.log('Task executed');
});
console.log(job.nextInvocation().toString());
process.exit(0);
