#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
#include <Arduino_LSM6DS3.h>
#include <WiFiNINA.h>
#include <FlashStorage.h>

// BLE services and characteristics
BLEService batteryService("180F"); // Standard battery service
BLEUnsignedCharCharacteristic batteryLevelChar("2A19", BLERead | BLENotify);

BLEService stepService("180D"); // Custom service for steps
BLEUnsignedIntCharacteristic stepCountCharacteristic("2A37", BLERead | BLENotify);

// Wi-Fi credentials
const char* ssid = "Razol_2.4EX";
const char* password = "0525706537";

// Server URL
const char* server = "34.230.176.208"; // Server URL

volatile int stepCount = 0;
long lastStepTime = 0;

// Collar ID variable
uint32_t collarID = 0;

// BLE and Wi-Fi connection timeouts (in milliseconds)
const unsigned long bleTimeout = 10000; // 10 seconds
const unsigned long wifiTimeout = 10000; // 10 seconds

// Connection state
enum ConnectionState {
  DISCONNECTED,
  CONNECTING_BLE,
  CONNECTED_BLE,
  CONNECTING_WIFI,
  CONNECTED_WIFI
};

ConnectionState currentState = DISCONNECTED;
unsigned long connectionStartTime = 0;

// Flash storage for step count
FlashStorage(storedStepCount, int);

void setup() {
  Serial.begin(9600);
  // Remove the while(!Serial) to allow the device to start without Serial connection

  // Initialize IMU
  if (!IMU.begin()) {
    // Handle IMU initialization failure
    while (1) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(100);
      digitalWrite(LED_BUILTIN, LOW);
      delay(100);
    }
  }

  // Obtain Chip ID
  for (int i = 0; i < 4; i++) {
    collarID |= ((uint32_t) *(uint8_t*)(0x0080A00C + i) << (i * 8));
  }

  // Initialize BLE
  if (!BLE.begin()) {
    // Handle BLE initialization failure
    while (1) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(200);
      digitalWrite(LED_BUILTIN, LOW);
      delay(200);
    }
  }

  // Initialize WiFi
  WiFi.setTimeout(wifiTimeout);
  
  // Restore step count from Flash
  stepCount = storedStepCount.read();
  if (stepCount < 0) stepCount = 0; // Ensure valid step count

  currentState = DISCONNECTED;
}

void loop() {
  if (detectStep()) {
    stepCount++;
    storedStepCount.write(stepCount); // Save step count to Flash
  }

  switch (currentState) {
    case DISCONNECTED:
      attemptBLEConnection();
      break;
    case CONNECTING_BLE:
      checkBLEConnection();
      break;
    case CONNECTED_BLE:
      handleBLEConnection();
      break;
    case CONNECTING_WIFI:
      checkWiFiConnection();
      break;
    case CONNECTED_WIFI:
      handleWiFiConnection();
      break;
  }

  // Implement power-saving delay
  delay(100);
}

bool detectStep() {
  float x, y, z;

  if (IMU.accelerationAvailable()) {
    IMU.readAcceleration(x, y, z);
    float magnitude = sqrt(x * x + y * y + z * z);

    long currentTime = millis();
    if (magnitude > 1.2 && (currentTime - lastStepTime) > 200) { // Adjust sensitivity and debounce time as needed
      lastStepTime = currentTime;
      return true;
    }
  }
  return false;
}

void attemptBLEConnection() {
  Serial.println("Attempting BLE connection");
  BLE.stopAdvertise();
  if (!BLE.advertise()) {
    Serial.println("Failed to start advertising");
    currentState = DISCONNECTED;
    return;
  }
  currentState = CONNECTING_BLE;
  connectionStartTime = millis();
}

void checkBLEConnection() {
  if (BLE.central()) {
    Serial.println("Connected to BLE central");
    currentState = CONNECTED_BLE;
  } else if (millis() - connectionStartTime > bleTimeout) {
    Serial.println("BLE connection attempt timed out");
    BLE.stopAdvertise();
    currentState = DISCONNECTED;
    attemptWiFiConnection();
  }
}

void handleBLEConnection() {
  BLEDevice central = BLE.central();
  if (central && central.connected()) {
    stepCountCharacteristic.writeValue(stepCount);
    updateBatteryLevel();
    BLE.poll();
  } else {
    Serial.println("BLE connection lost");
    currentState = DISCONNECTED;
  }
}

void attemptWiFiConnection() {
  Serial.println("Attempting Wi-Fi connection");
  BLE.end();  // End BLE before starting Wi-Fi
  WiFi.disconnect();  // Disconnect from any existing WiFi connection
  WiFi.end();
  delay(1000);  // Give some time for the WiFi to reset
  WiFi.begin(ssid, password);
  currentState = CONNECTING_WIFI;
  connectionStartTime = millis();
}

void checkWiFiConnection() {
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Connected to Wi-Fi");
    currentState = CONNECTED_WIFI;
  } else if (millis() - connectionStartTime > wifiTimeout) {
    Serial.println("Wi-Fi connection attempt timed out");
    WiFi.end();
    currentState = DISCONNECTED;
  }
}

void handleWiFiConnection() {
  static unsigned long lastTransmissionTime = 0;
  const unsigned long transmissionInterval = 5000; // 5 sec

  if (WiFi.status() == WL_CONNECTED) {
    unsigned long currentTime = millis();
    if (currentTime - lastTransmissionTime >= transmissionInterval) {
      sendDataViaHTTP(getBatteryLevel(), stepCount, collarID);
      lastTransmissionTime = currentTime;
    }
  } else {
    Serial.println("Wi-Fi connection lost");
    WiFi.disconnect();
    WiFi.end();
    currentState = DISCONNECTED;
  }
}

void updateBatteryLevel() {
  static unsigned long previousBatteryMillis = 0;
  const long batteryInterval = 2000;
  unsigned long currentMillis = millis();

  if (currentMillis - previousBatteryMillis >= batteryInterval) {
    previousBatteryMillis = currentMillis;
    int batteryLevel = getBatteryLevel();
    
    if (currentState == CONNECTED_BLE) {
      batteryLevelChar.writeValue(batteryLevel);
    }
  }
}

int getBatteryLevel() {
  int batteryLevel = analogRead(A0); // Mock battery level read
  return map(batteryLevel, 0, 1023, 0, 100); // Convert to percentage
}

void sendDataViaHTTP(int battery, int steps, uint32_t collarID) {
  WiFiClient client;

  if (client.connect(server, 5000)) {
    String putData = "battery=" + String(battery) + "&steps=" + String(steps) + "&collarID=" + String(collarID, HEX);
    
    // Send HTTP request
    client.println("PUT /api/dog/collar_data HTTP/1.1");
    client.println("Host: " + String(server));
    client.println("Content-Type: application/x-www-form-urlencoded");
    client.println("Content-Length: " + String(putData.length()));
    client.println();
    client.println(putData);

    Serial.println("sent to backend: ");
    Serial.println(steps);
    Serial.println("steps ");
    Serial.println(battery);
    Serial.println("% battery level |");

  } else {
    Serial.println("Connection to server failed.");
  }
  client.stop();
}