import { registerWebModule, NativeModule } from 'expo';

import { ExpoHealthKitModuleEvents } from './ExpoHealthKit.types';

class ExpoHealthKitModule extends NativeModule<ExpoHealthKitModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoHealthKitModule);
