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

    exports.createConvoyInvites = functions.firestore
        .document('convoys/{convoyID}/{membersCollectionID}/{memberID}')
        .onCreate((snap, context) => {
            if (context.params.membersCollectionID == "members") {
                const newMember = snap.data();
                if (newMember.status == "requested") {
                    let data = {
                        userUID: newMember.userUID,
                        convoyID: context.params.convoyID,
                        status: "sent"
                    }

                    admin.firestore().collection('convoyRequests').add(data)
                    .then(ref => {
                        console.log('Added convoy request with ID: ', ref.id);
                    });
                }
            }
        })

    exports.checkForMemberUpdates = functions.firestore
        .document('convoys/{convoyID}/{membersCollectionID}/{memberID}')
        .onUpdate((snap, context) => {
            if (context.params.membersCollectionID == "members") {
                const member = snap.data();
                if ((member.status == "declined") || (member.status == "not started")) {
                    admin.firestore().collection('convoyRequests').where('userUID', '==', member.userUID)
                        .where('convoyID', '==', context.params.convoyID).get()
                        .then(snapshot => {
                            if (snapshot.empty) {
                                console.log('No matching documents.');
                                return;
                            }

                            snapshot.forEach(doc => {
                                admin.firestore().collection('convoyRequests').doc(doc.id).delete();
                            });
                        })
                        .catch(err => {
                            console.log('Error getting documents', err);
                        });
                } else if (member.status == "arrived") {
                    admin.firestore().collection('convoys').doc(convoyID).collection(membersCollectionID).get()
                    .then(snapshot => {
                        var all = true;
                        snapshot.forEach(doc => {
                            let convoy = doc.data();
                            if((convoy.status == "not started") || (convy.status == "in progress")) {
                                all = false;
                            }
                        });

                        if (all) {
                            snapshot.forEach(doc => {
                                let id = doc.id;
                                admin.firestore().collection('convoys').doc(convoyID).collection(membersCollectionID).doc(id).update({status : "finished"})
                            });

                        }

                    })
                }
            }
        })
