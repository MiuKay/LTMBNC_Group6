const admin = require("firebase-admin");
const serviceAccount = require("../fitnessworkoutapp-601c0-firebase-adminsdk-at40n-a664c53983.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = admin;
