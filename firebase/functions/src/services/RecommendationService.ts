// firebase/functions/src/services/RecommendationService.ts

import axios from "axios";
import { Participant, TripOption } from "../models";

const DISTANCE_MATRIX_API_URL = "https://maps.googleapis.com/maps/api/distancematrix/json";

export class RecommendationService {
  private apiKey: string;

  constructor() {
    this.apiKey = process.env.PLACES_KEY ?? "";
    if (!this.apiKey) {
      console.error("Google API key not found in environment variables.");
      throw new Error("Google API key is not configured.");
    }
  }

  /**
   * Ranks a list of places based on fairness and other metrics, returning the top 3.
   * @param places - An array of TripOption candidates.
   * @param participants - An array of participants.
   * @returns A promise that resolves to the top 3 ranked TripOption objects.
   */
  public async rankPlaces(places: TripOption[], participants: Participant[]): Promise<TripOption[]> {
    if (places.length === 0 || participants.length === 0) {
      return [];
    }

    const participantOrigins = participants.map(p => `${p.location.latitude},${p.location.longitude}`).join("|");
    const placeDestinations = places.map(p => `place_id:${p.placeId}`).join("|");

    const travelTimes = await this.getTravelTimes(participantOrigins, placeDestinations);

    const scoredPlaces = places.map((place, index) => {
      const timesForPlace = travelTimes.map(row => row.elements[index]?.duration.value).filter(t => t !== undefined) as number[];
      const fairnessScore = this.calculateFairnessScore(timesForPlace);
      const ratingScore = place.rating ? place.rating / 5.0 : 0; // Normalize rating to 0-1
      const priceScore = place.priceLevel ? 1 - (place.priceLevel / 4.0) : 0.5; // Normalize price to 0-1 (higher is cheaper)

      // Weights for combining scores
      const weights = {
        fairness: 0.5,
        rating: 0.3,
        price: 0.2,
      };

      const totalScore = (weights.fairness * fairnessScore) + (weights.rating * ratingScore) + (weights.price * priceScore);

      return { ...place, score: totalScore };
    });

    // Sort by score in descending order and take the top 3
    return scoredPlaces.sort((a, b) => b.score - a.score).slice(0, 3);
  }

  /**
   * Calculates a fairness score based on the variance of travel times.
   * A lower variance means a fairer location. Score is normalized to 0-1.
   * @param times - An array of travel times in seconds.
   * @returns A normalized fairness score (1 is best, 0 is worst).
   */
  private calculateFairnessScore(times: number[]): number {
    if (times.length < 2) {
      return 1.0; // Perfectly fair if only one person
    }
    const mean = times.reduce((a, b) => a + b, 0) / times.length;
    const variance = times.reduce((sum, time) => sum + Math.pow(time - mean, 2), 0) / times.length;
    
    // Normalize variance to a 0-1 score. This is a simple normalization and can be improved.
    // Assuming a max variance of 3600 seconds (1 hour) for normalization.
    const maxVariance = 3600 * 3600; 
    return 1 - Math.min(variance / maxVariance, 1);
  }

  /**
   * Calls the Google Maps Distance Matrix API to get travel times.
   * @param origins - A string of piped origin coordinates.
   * @param destinations - A string of piped destination place IDs.
   * @returns The rows from the Distance Matrix API response.
   */
  private async getTravelTimes(origins: string, destinations: string): Promise<any[]> {
    const params = {
      origins,
      destinations,
      key: this.apiKey,
    };

    try {
      const response = await axios.get(DISTANCE_MATRIX_API_URL, { params });
      if (response.data.status !== "OK") {
        console.error("Distance Matrix API Error:", response.data.status, response.data.error_message);
        throw new Error("Failed to fetch travel times.");
      }
      return response.data.rows;
    } catch (error) {
      console.error("Error calling Distance Matrix API:", error);
      throw new Error("An unexpected error occurred while fetching travel times.");
    }
  }
}
