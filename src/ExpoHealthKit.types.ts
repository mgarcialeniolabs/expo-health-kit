// HealthKit data types
export type HealthKitDataType =
  | "steps"
  | "heartRate"
  | "activeEnergy"
  | "height"
  | "weight"
  | "bloodGlucose"
  | "bloodPressure";

export type PermissionsResponse = {
  success: boolean;
};

export type ExpoHealthKitModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
  onPermissionsResult: (params: PermissionsResponse) => void;
};

export type ChangeEventPayload = {
  value: string;
};
