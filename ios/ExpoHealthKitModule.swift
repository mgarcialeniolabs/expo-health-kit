import ExpoModulesCore
import HealthKit

public class ExpoHealthKitModule: Module {
  private let healthStore = HKHealthStore()
  
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ExpoHealthKit')` in JavaScript.
    Name("ExpoHealthKit")

    // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
    Constants([
      "PI": Double.pi
    ])

    // Defines event names that the module can send to JavaScript.
    Events("onChange", "onPermissionsResult")

    // Defines a JavaScript synchronous function that runs the native code on the JavaScript thread.
    Function("hello") {
      return "Hello world! 👋"
    }

    // Defines a JavaScript function that always returns a Promise and whose native code
    // is by default dispatched on the different thread than the JavaScript runtime runs on.
    AsyncFunction("setValueAsync") { (value: String) in
      // Send an event to JavaScript.
      self.sendEvent("onChange", [
        "value": value
      ])
    }
    
    // Check if HealthKit is available on the device
    AsyncFunction("isHealthKitAvailable") { () -> Bool in
      return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request permissions for steps data
    AsyncFunction("requestPermissions") { (promise: Promise) in
      guard HKHealthStore.isHealthDataAvailable() else {
        promise.reject(
          "E_HEALTHKIT_UNAVAILABLE",
          "HealthKit is not available on this device"
        )
        return
      }
      
      let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      
      // Request both read and write permissions for steps
      healthStore.requestAuthorization(toShare: [stepsType], read: [stepsType]) { success, error in
        if let error = error {
          promise.reject(
            "E_HEALTHKIT_PERMISSIONS",
            "Failed to request HealthKit permissions: \(error.localizedDescription)"
          )
          return
        }
        
        self.sendEvent("onPermissionsResult", [
          "success": success
        ])
        
        promise.resolve([
          "success": success
        ])
      }
    }
    
    // Fetch step count for a specific time period
    AsyncFunction("getStepCount") { (startTimestamp: Double, endTimestamp: Double, promise: Promise) in
      guard HKHealthStore.isHealthDataAvailable() else {
        promise.reject(
          "E_HEALTHKIT_UNAVAILABLE",
          "HealthKit is not available on this device"
        )
        return
      }
      
      // Convert timestamps to Date objects
      let startDate = Date(timeIntervalSince1970: startTimestamp / 1000.0)
      let endDate = Date(timeIntervalSince1970: endTimestamp / 1000.0)
      
      let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      
      let predicate = HKQuery.predicateForSamples(
        withStart: startDate,
        end: endDate,
        options: .strictStartDate
      )
      
      let query = HKStatisticsQuery(
        quantityType: stepsQuantityType,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
      ) { _, result, error in
        guard let result = result, let sum = result.sumQuantity() else {
          if let error = error {
            promise.reject(
              "E_HEALTHKIT_QUERY_ERROR",
              "Failed to fetch step count: \(error.localizedDescription)"
            )
          } else {
            promise.resolve(0)
          }
          return
        }
        
        let steps = sum.doubleValue(for: HKUnit.count())
        promise.resolve(steps)
      }
      
      healthStore.execute(query)
    }
    
    // Save step count data to HealthKit
    AsyncFunction("saveStepCount") { (steps: Double, startTimestamp: Double, endTimestamp: Double, promise: Promise) in
      guard HKHealthStore.isHealthDataAvailable() else {
        promise.reject(
          "E_HEALTHKIT_UNAVAILABLE",
          "HealthKit is not available on this device"
        )
        return
      }
      
      // Convert timestamps to Date objects
      let startDate = Date(timeIntervalSince1970: startTimestamp / 1000.0)
      let endDate = Date(timeIntervalSince1970: endTimestamp / 1000.0)
      
      let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      
      // Create a quantity sample
      let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: steps)
      let sample = HKQuantitySample(
        type: stepsQuantityType,
        quantity: quantity,
        start: startDate,
        end: endDate
      )
      
      // Save the sample to HealthKit
      healthStore.save(sample) { success, error in
        if let error = error {
          promise.reject(
            "E_HEALTHKIT_SAVE_ERROR",
            "Failed to save step count data: \(error.localizedDescription)"
          )
          return
        }
        
        promise.resolve(success)
      }
    }
    
    // Check if HealthKit is available and authorized for the requested data types
    AsyncFunction("getAuthorizationStatus") { (promise: Promise) in
      // Check if HealthKit is available on the device
      let isAvailable = HKHealthStore.isHealthDataAvailable()
      
      if !isAvailable {
        promise.resolve([
          "isAvailable": false,
          "isAuthorized": false,
          "canRead": false,
          "canWrite": false
        ])
        return
      }
      
      // Check authorization status for step count
      let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      
      let authStatus = healthStore.authorizationStatus(for: stepsType)
      
      // Check different authorization statuses
      let canRead = (authStatus == .sharingAuthorized)
      let canWrite = (authStatus == .sharingAuthorized)
      let isAuthorized = canRead || canWrite
      
      promise.resolve([
        "isAvailable": true,
        "isAuthorized": isAuthorized,
        "canRead": canRead,
        "canWrite": canWrite
      ])
    }
  }
}
