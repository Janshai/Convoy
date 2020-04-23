const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.addUserToDB = functions.auth.user().onCreate((user) => {
    let data = {
        userUID: user.uid,
        email: user.email,
        displayName: user.displayName
    }
    return admin.firestore().collection('users').add(data)
    .then(ref => {
        console.log('Added document with ID: ', ref.id);
    });
});
