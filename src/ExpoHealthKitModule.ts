import { NativeModule, requireNativeModule } from "expo";

import {
  ExpoHealthKitModuleEvents,
  PermissionsResponse,
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
   * Request permissions for step count data
   */
  requestPermissions(): Promise<PermissionsResponse>;

  /**
   * Get step count between two dates
   * @param startDate Start date for the query
   * @param endDate End date for the query
   */
  getStepCount(startDate: Date, endDate: Date): Promise<number>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoHealthKitModule>("ExpoHealthKit");
