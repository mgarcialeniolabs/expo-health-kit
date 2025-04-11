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
          exception: "E_HEALTHKIT_UNAVAILABLE",
          message: "HealthKit is not available on this device"
        )
        return
      }
      
      let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
      
      healthStore.requestAuthorization(toShare: [], read: [stepsType]) { success, error in
        if let error = error {
          promise.reject(
            exception: "E_HEALTHKIT_PERMISSIONS",
            message: "Failed to request HealthKit permissions: \(error.localizedDescription)"
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
    AsyncFunction("getStepCount") { (startDate: Date, endDate: Date, promise: Promise) in
      guard HKHealthStore.isHealthDataAvailable() else {
        promise.reject(
          exception: "E_HEALTHKIT_UNAVAILABLE",
          message: "HealthKit is not available on this device"
        )
        return
      }
      
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
              exception: "E_HEALTHKIT_QUERY_ERROR",
              message: "Failed to fetch step count: \(error.localizedDescription)"
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
  }
}
