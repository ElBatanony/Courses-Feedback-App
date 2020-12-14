import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
const language = require('@google-cloud/language');

admin.initializeApp();

const db = admin.firestore();

exports.modifyRating = functions.firestore
    .document('ta-course/{taCourseId}/ratings/{uid}')
    .onWrite(async (change, context) => {

        const taCourseId = context.params.taCourseId;
        const uid = context.params.uid;

        const newData = change.after.exists ? change.after.data() : null;
        const oldData = change.before.exists ? change.before.data() : null;

        const taCourseDoc = db.collection('ta-course').doc(taCourseId)

        let newTaCourse: any = {};

        if (newData && newData.rating)
            newTaCourse['rating' + newData.rating.toString()] = admin.firestore.FieldValue.arrayUnion(uid);

        if (oldData && oldData.rating)
            newTaCourse['rating' + oldData.rating.toString()] = admin.firestore.FieldValue.arrayRemove(uid);

        return taCourseDoc.update(newTaCourse);
    });

exports.postFeedback = functions.firestore
    .document('feedback/{feedbackId}')
    .onCreate(async (snap, context) => {

        const client = new language.LanguageServiceClient();

        const feedbackData = snap.data();

        const document = {
            content: feedbackData.message || '',
            type: 'PLAIN_TEXT',
        };

        const [result] = await client.analyzeSentiment({ document: document });
        const sentiment = result.documentSentiment; // contains a score and a magnitude

        return snap.ref.update({ sentiment });
    });