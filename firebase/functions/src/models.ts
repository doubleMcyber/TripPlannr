// firebase/functions/src/models.ts

// Using 'export' to make these interfaces and enums available in other files.

export enum TripCategory {
  Food = "Food",
  Drinks = "Drinks",
  CoffeeTea = "Coffee/Tea",
  Dessert = "Dessert",
  ScenicSpot = "Scenic Spot",
  NoPreference = "No Preference",
}

export enum PollState {
  Gathering = "gathering",
  Voting = "voting",
  Finished = "finished",
}

export enum TravelMode {
  Walk = "Walk",
  Drive = "Drive",
  Uber = "Uber/Taxi",
}

export interface Preferences {
  activityType?: string;
  diet?: string;
  price?: number;
  travelMode?: TravelMode;
}

import { GeoPoint } from "firebase-admin/firestore";

// ...

export interface Participant {
  id?: string;
  name: string;
  avatar: string;
  location: GeoPoint;
  preferences?: Preferences;
}

export interface Session {
  id?: string;
  hostId: string;
  createdAt: Date;
  category: TripCategory;
  pollState: PollState;
  participants: Participant[];
}

export interface TripOption {
  placeId: string;
  name: string;
  rating: number;
  priceLevel: number;
  votes: number;
  vibeDescription: string;
  coordinate: {
    latitude: number;
    longitude: number;
  };
}

export interface Poll {
  id?: string;
  options: TripOption[];
  voters: string[];
}
