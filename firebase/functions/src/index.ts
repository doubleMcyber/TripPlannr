// firebase/functions/src/index.ts

import { onCall, HttpsError, CallableRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { TripCategory, PollState, Participant, Poll } from "./models";
import { PlacesService } from "./services/PlacesService";
import { RecommendationService } from "./services/RecommendationService";

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

/**
 * Creates a new session document in Firestore.
 */
export const createSession = onCall(async (request: CallableRequest<any>) => {
  // Ensure the user is authenticated
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const { category } = request.data;
  const hostId = request.auth.uid;

  // Validate the category
  if (!Object.values(TripCategory).includes(category)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid category provided."
    );
  }

  try {
    const sessionRef = await db.collection("sessions").add({
      hostId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      category,
      pollState: PollState.Gathering,
    });

    return { sessionId: sessionRef.id };
  } catch (error) {
    console.error("Error creating session:", error);
    throw new HttpsError(
      "internal",
      "An error occurred while creating the session."
    );
  }
});

/**
 * Adds a participant to a session.
 */
export const joinSession = onCall(async (request: CallableRequest<any>) => {
    const { sessionId, name, location, preferences } = request.data;

  // Validate required data
  if (!sessionId || !name || !location) {
    throw new HttpsError(
      "invalid-argument",
      "Missing required data for joining a session."
    );
  }

  const sessionRef = db.collection("sessions").doc(sessionId);

  try {
    const doc = await sessionRef.get();
    if (!doc.exists) {
      throw new HttpsError(
        "not-found",
        "Session not found."
      );
    }
    
    // Add participant to the 'participants' subcollection
    const participant: Participant = {
        name,
        avatar: "default_avatar_url", // Placeholder for avatar logic
        location,
        preferences
    };

    const participantRef = await sessionRef.collection("participants").add(participant);

    return { participantId: participantRef.id };
  } catch (error) {
    console.error("Error joining session:", error);
    throw new HttpsError(
      "internal",
      "An error occurred while joining the session."
    );
  }
});

/**
 * Generates place recommendations for a session.
 */
export const generatePlaces = onCall(async (request: CallableRequest<any>) => {
  const { sessionId } = request.data;
  if (!sessionId) {
    throw new HttpsError(
      "invalid-argument",
      "Missing sessionId."
    );
  }

  const sessionRef = db.collection("sessions").doc(sessionId);
  const participantsRef = sessionRef.collection("participants");

  try {
    const sessionDoc = await sessionRef.get();
    if (!sessionDoc.exists) {
      throw new HttpsError("not-found", "Session not found.");
    }
    const sessionData = sessionDoc.data() as { category: TripCategory };
    
    const participantsSnapshot = await participantsRef.get();
    const participants = participantsSnapshot.docs.map(doc => doc.data() as Participant);

    if (participants.length === 0) {
      throw new HttpsError("failed-precondition", "Cannot generate places without participants.");
    }

    const placesService = new PlacesService();
    const recommendationService = new RecommendationService();

    const candidatePlaces = await placesService.findBestPlaces(participants, sessionData.category);
    const top3Places = await recommendationService.rankPlaces(candidatePlaces, participants);
    
    // Create a poll document
    const pollRef = db.collection("polls").doc(sessionId);
    await pollRef.set({
      options: top3Places,
      voters: [],
    });

    // Update the session's pollState
    await sessionRef.update({ pollState: PollState.Voting });

    return { success: true, message: "Successfully generated places and created a poll." };

  } catch (error) {
    console.error("Error generating places:", error);
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "An unexpected error occurred while generating places.");
  }
});

/**
 * Records a vote for a poll option.
 */
export const vote = onCall(async (request: CallableRequest<any>) => {
  const { sessionId, optionId } = request.data;

  // 1. Validate user authentication
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be logged in to vote.");
  }
  const userId = request.auth.uid;

  if (!sessionId || !optionId) {
    throw new HttpsError("invalid-argument", "Missing sessionId or optionId.");
  }

  const pollRef = db.collection("polls").doc(sessionId);

  try {
    return await db.runTransaction(async (transaction) => {
      const pollDoc = await transaction.get(pollRef);
      if (!pollDoc.exists) {
        throw new HttpsError("not-found", "Poll not found.");
      }

      const pollData = pollDoc.data() as Poll;

      // 2. Check if user has already voted
      if (pollData.voters.includes(userId)) {
        throw new HttpsError("failed-precondition", "You have already voted.");
      }

      // 3. Find the option and increment its vote count
      const optionIndex = pollData.options.findIndex(option => option.placeId === optionId);
      if (optionIndex === -1) {
        throw new HttpsError("not-found", "Poll option not found.");
      }
      
      pollData.options[optionIndex].votes += 1;
      pollData.voters.push(userId);
      
      // 4. Update the document in the transaction
      transaction.update(pollRef, {
        options: pollData.options,
        voters: pollData.voters,
      });
      
      return { success: true, message: "Vote successfully recorded." };
    });
  } catch (error) {
    console.error("Error voting:", error);
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "An unexpected error occurred while voting.");
  }
});