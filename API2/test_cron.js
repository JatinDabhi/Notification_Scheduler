const schedule = require('node-schedule');
const job = schedule.scheduleJob('03 15 * * *', () => {
    console.log('Task executed');
});
console.log(job.nextInvocation().toString());
process.exit(0);
