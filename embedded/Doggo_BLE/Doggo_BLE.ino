#include <ArduinoBLE.h>

BLEService batteryService("180F"); // Standard battery service

// BLE Battery Level Characteristic
BLEUnsignedCharCharacteristic batteryLevelChar("2A19", BLERead | BLENotify);

void setup() {
  Serial.begin(9600);
  while (!Serial); // Wait for the serial connection to establish

  Serial.println("Starting BLE setup...");

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  // Print the Bluetooth address
  Serial.print("Bluetooth Address: ");
  Serial.println(BLE.address());

  // set advertised local name and service UUID:
  BLE.setLocalName("DoggoCollar");
  BLE.setAdvertisedService(batteryService);

  // add the characteristic to the service
  batteryService.addCharacteristic(batteryLevelChar);

  // add service
  BLE.addService(batteryService);

  // set initial value for this characteristic
  batteryLevelChar.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("BLE Battery Monitor setup complete");
}

void loop() {
  // poll for BLE events
  BLE.poll();

  static unsigned long previousMillis = 0;
  const long interval = 2000;

  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    int batteryLevel = analogRead(A0); // Mock battery level read
    batteryLevel = map(batteryLevel, 0, 1023, 0, 100); // Convert to percentage

    Serial.print("Battery Level %: ");
    Serial.println(batteryLevel);

    batteryLevelChar.writeValue(batteryLevel);
    }
}
