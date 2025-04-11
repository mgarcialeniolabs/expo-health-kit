import * as React from 'react';

import { ExpoHealthKitViewProps } from './ExpoHealthKit.types';

export default function ExpoHealthKitView(props: ExpoHealthKitViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
