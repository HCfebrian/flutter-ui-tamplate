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