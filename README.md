# expo-health-kit

HealthKit integration for Expo apps, focused on step count data.

## Installation

```
expo install expo-health-kit
```

## Configuration

### iOS

1. Open your iOS project's Info.plist file and add the following permissions:

```xml
<key>NSHealthShareUsageDescription</key>
<string>This app requires access to your step count data to track your activity.</string>
```

2. Enable HealthKit capabilities in your Xcode project:
   - Open your project in Xcode
   - Select your target
   - Go to the "Signing & Capabilities" tab
   - Click "+" and add "HealthKit"

## API

### isHealthKitAvailable()

Check if HealthKit is available on the current device.

```javascript
import ExpoHealthKit from "expo-health-kit";

const isAvailable = ExpoHealthKit.isHealthKitAvailable();
console.log(`HealthKit available: ${isAvailable}`);
```

### requestPermissions()

Request permissions for step count data.

```javascript
import ExpoHealthKit from "expo-health-kit";

// Request permissions for steps
const result = await ExpoHealthKit.requestPermissions();

console.log(`Permission result: ${result.success}`);
```

### getStepCount(startDate, endDate)

Get step count between two dates.

```javascript
import ExpoHealthKit from "expo-health-kit";

// Get steps for today
const now = new Date();
const startOfDay = new Date(now.setHours(0, 0, 0, 0));
const steps = await ExpoHealthKit.getStepCount(startOfDay, new Date());

console.log(`Steps today: ${steps}`);
```

## Events

### onPermissionsResult

Emitted when permission request completes.

```javascript
import { useEffect } from "react";
import ExpoHealthKit from "expo-health-kit";

useEffect(() => {
  const subscription = ExpoHealthKit.addListener(
    "onPermissionsResult",
    (event) => {
      console.log(`Permission result: ${event.success}`);
    }
  );

  return () => {
    subscription.remove();
  };
}, []);
```

## Example

```javascript
import React, { useEffect, useState } from "react";
import { StyleSheet, Text, View, Button } from "react-native";
import ExpoHealthKit from "expo-health-kit";

export default function App() {
  const [isAvailable, setIsAvailable] = useState(false);
  const [hasPermissions, setHasPermissions] = useState(false);
  const [steps, setSteps] = useState(0);

  useEffect(() => {
    // Check if HealthKit is available
    const available = ExpoHealthKit.isHealthKitAvailable();
    setIsAvailable(available);
  }, []);

  const requestPermissions = async () => {
    if (!isAvailable) return;

    const result = await ExpoHealthKit.requestPermissions();
    setHasPermissions(result.success);
  };

  const fetchStepData = async () => {
    if (!hasPermissions) return;

    // Get steps for today
    const now = new Date();
    const startOfDay = new Date(now.setHours(0, 0, 0, 0));
    const stepsToday = await ExpoHealthKit.getStepCount(startOfDay, new Date());
    setSteps(stepsToday);
  };

  return (
    <View style={styles.container}>
      <Text>HealthKit Available: {isAvailable ? "Yes" : "No"}</Text>
      <Text>Has Permissions: {hasPermissions ? "Yes" : "No"}</Text>

      <Button
        title="Request Permissions"
        onPress={requestPermissions}
        disabled={!isAvailable}
      />

      <Button
        title="Fetch Step Data"
        onPress={fetchStepData}
        disabled={!hasPermissions}
      />

      <Text>Steps today: {steps}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
    padding: 20,
    gap: 10,
  },
});
```
