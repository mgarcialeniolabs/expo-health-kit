// Reexport the native module. On web, it will be resolved to ExpoHealthKitModule.web.ts
// and on native platforms to ExpoHealthKitModule.ts
export { default } from './ExpoHealthKitModule';
export { default as ExpoHealthKitView } from './ExpoHealthKitView';
export * from  './ExpoHealthKit.types';
