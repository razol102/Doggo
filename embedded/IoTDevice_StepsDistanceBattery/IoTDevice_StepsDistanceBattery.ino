#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
#include <Arduino_LSM6DS3.h>

// BLE services and characteristics
BLEService batteryService("180F"); // Standard battery service
BLEUnsignedCharCharacteristic batteryLevelChar("2A19", BLERead | BLENotify);

BLEService stepService("180D"); // Custom service for steps
BLEUnsignedIntCharacteristic stepCountCharacteristic("2A37", BLERead | BLENotify);

BLEService distanceService("181A"); // Custom service for distance (new service)
BLEFloatCharacteristic distanceCharacteristic("2A76", BLERead | BLENotify); // Custom characteristic for distance

volatile int stepCount = 0;
long lastStepTime = 0;
const float stepLength = 0.0006; // Average step length in kilometers (0.6 meters)

void setup() {
  Serial.begin(9600);
  while (!Serial); // Wait for the serial connection to establish

  Serial.println("Starting BLE setup...");

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  // Print the Bluetooth address
  Serial.print("Bluetooth Address: ");
  Serial.println(BLE.address());

  // Set advertised local name and service UUID
  BLE.setLocalName("DoggoCollar");
  
  // Advertise all services
  BLE.setAdvertisedService(batteryService);
  BLE.setAdvertisedService(stepService);
  BLE.setAdvertisedService(distanceService); // Advertise distance service

  // Add the characteristics to the services
  batteryService.addCharacteristic(batteryLevelChar);
  stepService.addCharacteristic(stepCountCharacteristic);
  distanceService.addCharacteristic(distanceCharacteristic); // Add distance characteristic to the distance service

  // Add services
  BLE.addService(batteryService);
  BLE.addService(stepService);
  BLE.addService(distanceService); // Add the distance service

  // Set initial values for the characteristics
  batteryLevelChar.writeValue(0);
  stepCountCharacteristic.writeValue(stepCount);
  distanceCharacteristic.writeValue(0.0f); // Initialize distance

  // Start advertising
  BLE.advertise();

  Serial.println("BLE Battery Monitor, Step Counter, and Distance Tracker setup complete");

  // Initialize IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
}

void loop() {
  // Poll for BLE events
  BLE.poll();

  // Battery monitoring
  static unsigned long previousBatteryMillis = 0;
  const long batteryInterval = 2000;
  unsigned long currentMillis = millis();

  if (currentMillis - previousBatteryMillis >= batteryInterval) {
    previousBatteryMillis = currentMillis;

    int batteryLevel = analogRead(A0); // Mock battery level read
    batteryLevel = map(batteryLevel, 0, 1023, 0, 100); // Convert to percentage

    Serial.print("Battery Level %: ");
    Serial.println(batteryLevel);

    batteryLevelChar.writeValue(batteryLevel);
  }

  // Step counting and distance calculation
  if (detectStep()) {
    stepCount++;
    stepCountCharacteristic.writeValue(stepCount);

    float distance = stepCount * stepLength; // Calculate distance in kilometers
    distanceCharacteristic.writeValue(distance); // Send distance value via BLE

    Serial.print("Step count: ");
    Serial.println(stepCount);
    Serial.print("Distance (km): ");
    Serial.println(distance, 4); // Print distance with 4 decimal places
  }

  delay(100); // Adjust delay based on your dog's step frequency
}

bool detectStep() {
  float x, y, z;

  // Check if acceleration data is available
  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(x, y, z);

    // Calculate the magnitude of acceleration
    float magnitude = sqrt(x * x + y * y + z * z);

    // Check if the magnitude exceeds the threshold and debounce time
    long currentTime = millis();
    if (magnitude > 1.2 && (currentTime - lastStepTime) > 200) { // Adjust sensitivity and debounce time as needed
      lastStepTime = currentTime;
      return true;
    }
  }
  return false;
}
