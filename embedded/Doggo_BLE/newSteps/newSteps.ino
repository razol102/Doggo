#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>

// Define the BLE service and characteristic
BLEService stepService("180D"); // Custom service UUID
BLEUnsignedIntCharacteristic stepCountCharacteristic("2A37", BLERead | BLENotify);

volatile int stepCount = 0;
long lastStepTime = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("DogStepCounter");
  BLE.setAdvertisedService(stepService);
  stepService.addCharacteristic(stepCountCharacteristic);
  BLE.addService(stepService);
  stepCountCharacteristic.writeValue(stepCount);

  BLE.advertise();
  Serial.println("BLE device is now advertising");

  // Initialize IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
}

void loop() {
  // Continuously check for steps and update BLE characteristic
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
