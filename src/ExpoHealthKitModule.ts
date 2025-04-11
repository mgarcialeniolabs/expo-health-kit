import { NativeModule, requireNativeModule } from "expo";

import {
  ExpoHealthKitModuleEvents,
  PermissionsResponse,
  AuthorizationStatusResponse,
} from "./ExpoHealthKit.types";

declare class ExpoHealthKitModule extends NativeModule<ExpoHealthKitModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;

  /**
   * Check if HealthKit is available on the device
   */
  isHealthKitAvailable(): boolean;

  /**
   * Request permissions for reading and writing step count data
   */
  requestPermissions(): Promise<PermissionsResponse>;

  /**
   * Get step count between two dates
   * @param startDate Start date for the query
   * @param endDate End date for the query
   */
  getStepCount(startDate: number, endDate: number): Promise<number>;

  /**
   * Save step count data to HealthKit
   * @param steps Number of steps to save
   * @param startDate Start date for the step count sample
   * @param endDate End date for the step count sample
   */
  saveStepCount(
    steps: number,
    startDate: number,
    endDate: number
  ): Promise<boolean>;

  /**
   * Check if HealthKit is available and if step count data has been authorized for reading/writing
   * @returns Object with isAvailable, isAuthorized, canRead, and canWrite status
   */
  getAuthorizationStatus(): Promise<AuthorizationStatusResponse>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoHealthKitModule>("ExpoHealthKit");
