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
    };
    return admin.firestore().collection('users').add(data)
    .then(ref => {
        console.log('Added document with ID: ', ref.id);
    });
});

exports.makeChangesOnFriendRequestUpdate = functions.firestore
    .document('friendRequests/{docID}')
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        console.log(newValue);
        if (newValue.status == "accepted") {
            console.log("accepted");
            let friendship = {
                friend1: newValue.sender,
                friend2: newValue.receiver
            };
            return admin.firestore().collection('friends').add(friendship)
            .then(ref => {
                console.log('Added friendship with ID: ', ref.id);
                let id = context.params.docID
                return admin.firestore().collection('friendRequests').doc(id).delete().then(ref => {
                    console.log('Added document with ID: ', ref.id);
                });
            });
        } else if (newValue.status == "rejected") {
            let id = context.params.docID
            return admin.firestore().collection('friendRequests').doc(id).delete().then(ref => {
                console.log('Added document with ID: ', ref.id);
            });
        }
    });
