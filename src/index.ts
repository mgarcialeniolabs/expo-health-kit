// Reexport the native module. On web, it will be resolved to ExpoHealthKitModule.web.ts
// and on native platforms to ExpoHealthKitModule.ts
export { default } from "./ExpoHealthKitModule";
export * from "./ExpoHealthKit.types";
