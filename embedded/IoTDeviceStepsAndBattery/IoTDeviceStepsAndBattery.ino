#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
#include <Arduino_LSM6DS3.h>

// BLE services and characteristics
BLEService batteryService("180F"); // Standard battery service
BLEUnsignedCharCharacteristic batteryLevelChar("2A19", BLERead | BLENotify);

BLEService stepService("180D"); // Custom service UUID
BLEUnsignedIntCharacteristic stepCountCharacteristic("2A37", BLERead | BLENotify);

volatile int stepCount = 0;
long lastStepTime = 0;

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
  BLE.setAdvertisedService(batteryService);
  BLE.setAdvertisedService(stepService);

  // Add the characteristics to the services
  batteryService.addCharacteristic(batteryLevelChar);
  stepService.addCharacteristic(stepCountCharacteristic);

  // Add services
  BLE.addService(batteryService);
  BLE.addService(stepService);

  // Set initial values for the characteristics
  batteryLevelChar.writeValue(0);
  stepCountCharacteristic.writeValue(stepCount);

  // Start advertising
  BLE.advertise();

  Serial.println("BLE Battery Monitor and Step Counter setup complete");

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

  // Step counting
  if (detectStep()) {
    stepCount++;
    stepCountCharacteristic.writeValue(stepCount);
    Serial.print("Step count: ");
    Serial.println(stepCount);
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