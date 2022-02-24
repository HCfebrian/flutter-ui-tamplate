const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.changeMessageStatus = functions.firestore
  .document('rooms/{roomId}/messages/{messageId}')
  .onWrite((change) => {
    const message = change.after.data()
    if (message) {
      if (['delivered', 'seen', 'sent'].includes(message.status)) {
        return null
      } else {
        return change.after.ref.update({
          status: 'delivered',
        })
      }
    } else {
      return null
    }
  })

exports.onUserStatusChanged = functions.database.ref('/status/{uid}').onUpdate(
    async (change, context) => {
      // Get the data written to Realtime Database
      const eventStatus = change.after.val();

      // Then use other event data to create a reference to the
      // corresponding Firestore document.
      const userStatusFirestoreRef = admin.firestore().doc(`users/${context.params.uid}`);

      // It is likely that the Realtime Database change that triggered
      // this event has already been overwritten by a fast change in
      // online / offline status, so we'll re-read the current data
      // and compare the timestamps.
      const statusSnapshot = await change.after.ref.once('value');
      const status = statusSnapshot.val();
      functions.logger.log(status, eventStatus);
      // If the current timestamp for this data is newer than
      // the data that triggered this event, we exit this function.
      if (status.last_changed > eventStatus.last_changed) {
        return null;
      }

      // Otherwise, we convert the last_changed field to a Date
      eventStatus.last_changed = new Date(eventStatus.last_changed);

      // ... and write it to Firestore.
      return userStatusFirestoreRef.update(eventStatus);
    });
    
exports.notifyNewMessage = functions.firestore
    .document('rooms/{roomId}/messages/{messageId}')
    .onCreate((docSnapshot, context) => {
        const message = docSnapshot.data();
        const authorId = message['authorId'];
        const roomId = context.params.roomId;

        return admin.firestore().doc('rooms/' + roomId).get().then(roomDoc => {
          var userIds = Array();  
          userIds = roomDoc.get('userIds');
            userIds.forEach((userId)=>{
              if(userId != authorId){
                
                return admin.firestore().doc('users/'+userId).get().then((user)=>{
                  const fcmToken = user.get("fcmTokenDevice");
                  const senderName = user.get("firstName");
                  const notificationBody = (message['type'] === "text") ? message['text'] : "You received a new message."
                const payload = {
                    notification: {
                        title: senderName,
                        body: notificationBody,
                        clickAction: "ChatActivity"
                    },
                    data: {
                        AUTHOR_ID: authorId,
                        ROOM_ID: roomId
                    }
                }
                  return admin.messaging().sendToDevice(fcmToken, payload).then( response => {
                    return response.results.forEach((result, index) => {
                        const error = result.error
                        if (error) {
                            const failedRegistrationToken = userId[index]
                            console.error('blah', failedRegistrationToken, error)
                            if (error.code === 'messaging/invalid-registration-token'
                                || error.code === 'messaging/registration-token-not-registered') {
                                    if (failedIndex > -1) {
                                    }
                                }
                        }
                    })
                })
                });
                              

              }

            });
        })
    })