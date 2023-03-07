var apn = require('apn');

const options = {
  token: {
    key: '*',
    keyId: '*',
    teamId: '*'
  },
  production: false
};

var apnProvider = new apn.Provider(options);

// Sending the voip notification
let notification = new apn.Notification();

notification.body = "*";
notification.topic = "*";
notification.payload = {
  callStatus: "ended",
}
const deviceToken = '*'
apnProvider.send(notification, deviceToken).then((response) => {
  console.log(response, 'response');
});
 