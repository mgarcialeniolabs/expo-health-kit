import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoHealthKitViewProps } from './ExpoHealthKit.types';

const NativeView: React.ComponentType<ExpoHealthKitViewProps> =
  requireNativeView('ExpoHealthKit');

export default function ExpoHealthKitView(props: ExpoHealthKitViewProps) {
  return <NativeView {...props} />;
}
