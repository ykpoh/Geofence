## Project information
1. Xcode 12.2
2. iOS Deployment Target: 14.2

## Steps to set up
1. Clone the repository into your local directory.
2. Ensure you opened with **Xcode 12.2 or newer version**.
3. Run the project in simulator or into your device.

## Testing
1. First of all, wifi setting is not available in iOS simulator, so you will have to install into your device in order to test getting the ssid/wifi name.
2. You can test the GPS location with your device or go to edit scheme > Options > Check "Allow Location Simulation" > Select "SimulatedLocations".
3. Then, edit SimulatedLocations.gpx file in the project to your preferred simulated locations and start testing.

## Future Improvement:
1. Unit Test
2. Running in background and trigger notifications when enter or exit region.