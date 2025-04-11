import { NativeModule, requireNativeModule } from 'expo';

import { ExpoHealthKitModuleEvents } from './ExpoHealthKit.types';

declare class ExpoHealthKitModule extends NativeModule<ExpoHealthKitModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoHealthKitModule>('ExpoHealthKit');
