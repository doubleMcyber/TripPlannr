// firebase/functions/src/services/PlacesService.ts

import axios from "axios";
import { GeoPoint } from "firebase-admin/firestore";
import { TripCategory, TripOption } from "../models";

// Base URL for Google Places API
const PLACES_API_BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

export class PlacesService {
  private apiKey: string;

  constructor() {
    // Use environment variables for the API key
    this.apiKey = process.env.PLACES_KEY ?? "";
    if (!this.apiKey) {
      console.error("Google Places API key not found in environment variables.");
      throw new Error("Google Places API key is not configured.");
    }
  }

  /**
   * Finds the best places for a trip based on participant locations and a category.
   * @param participants - An array of participant objects with their locations.
   * @param category - The category of the trip.
   * @returns A promise that resolves to an array of TripOption objects.
   */
  public async findBestPlaces(participants: { location: GeoPoint }[], category: TripCategory): Promise<TripOption[]> {
    if (participants.length === 0) {
      return [];
    }

    const centralPoint = this.calculateCentroid(participants.map(p => p.location));
    const searchRadius = 5000; // 5km radius, can be adjusted

    const params = {
      location: `${centralPoint.latitude},${centralPoint.longitude}`,
      radius: searchRadius.toString(),
      type: this.getPlaceTypeForCategory(category),
      key: this.apiKey,
    };

    try {
      const response = await axios.get(PLACES_API_BASE_URL, { params });

      if (response.data.status !== "OK") {
        console.error("Google Places API Error:", response.data.status, response.data.error_message);
        throw new Error("Failed to fetch places from Google Places API.");
      }

      // Map the results to our TripOption model
      return response.data.results.map((place: any): TripOption => ({
        placeId: place.place_id,
        name: place.name,
        rating: place.rating,
        priceLevel: place.price_level,
        vibeDescription: place.vicinity, // Using vicinity as a simple "vibe"
        votes: 0,
        coordinate: {
            latitude: place.geometry.location.lat,
            longitude: place.geometry.location.lng,
        }
      }));
    } catch (error) {
      console.error("Error calling Google Places API:", error);
      throw new Error("An unexpected error occurred while fetching places.");
    }
  }

  /**
   * Calculates the centroid (geographic center) of a list of geo-coordinates.
   * @param locations - An array of GeoPoint objects.
   * @returns A GeoPoint representing the centroid.
   */
  private calculateCentroid(locations: GeoPoint[]): GeoPoint {
    if (locations.length === 0) {
        throw new Error("Cannot calculate centroid of empty locations array.");
    }
    
    const totalLat = locations.reduce((sum, loc) => sum + loc.latitude, 0);
    const totalLng = locations.reduce((sum, loc) => sum + loc.longitude, 0);

    return new GeoPoint(totalLat / locations.length, totalLng / locations.length);
  }

  /**
   * Maps a TripCategory to a corresponding Google Places API place type.
   * @param category - The trip category.
   * @returns A string representing the Google Places API place type.
   */
  private getPlaceTypeForCategory(category: TripCategory): string {
    switch (category) {
      case TripCategory.Food:
        return "restaurant";
      case TripCategory.Drinks:
        return "bar";
      case TripCategory.CoffeeTea:
        return "cafe";
      case TripCategory.Dessert:
        return "bakery";
      case TripCategory.ScenicSpot:
        return "tourist_attraction";
      default:
        return "point_of_interest";
    }
  }
}
