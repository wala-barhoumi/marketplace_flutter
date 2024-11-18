const admin = require("firebase-admin");
const express = require("express");

// Initialize Firebase Admin SDK with your service account credentials
const serviceAccount =require(
    "marketplace-flutter-b74b7-firebase-adminsdk-s90zg-5b32dc7bf8.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://marketplace-flutter-b74b7-default-rtdb.firebaseio.com/",
});

// Initialize Firestore
const db = admin.firestore();
const app = express();
