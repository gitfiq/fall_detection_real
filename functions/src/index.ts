import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const sendFallNotification = functions.firestore
  .document("users/{userId}/about/fall indication")
  .onUpdate(async (change, context) => {
    const fallStatus = change.after.get("fall_status");
    const userId = context.params.userId;

    if (fallStatus === true) {
      const message = {
        notification: {
          title: "Fall Detected!",
          body: "A fall has been detected. Please check on the user.",
        },
        topic: `detectfall_${userId}`,
      };

      try {
        await admin.messaging().send(message);
        console.log("Notification sent successfully");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    }
  });

