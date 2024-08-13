#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
#include <Arduino_LSM6DS3.h>
#include <WiFiNINA.h>

// BLE services and characteristics
BLEService batteryService("180F"); // Standard battery service
BLEUnsignedCharCharacteristic batteryLevelChar("2A19", BLERead | BLENotify);

BLEService stepService("180D"); // Custom service for steps
BLEUnsignedIntCharacteristic stepCountCharacteristic("2A37", BLERead | BLENotify);

BLEService distanceService("181A"); // Custom service for distance (updated to meters)
BLEUnsignedIntCharacteristic distanceCharacteristic("2A76", BLERead | BLENotify); // Custom characteristic for distance in meters

// Wi-Fi credentials
const char* ssid = "MTA WiFi";
const char* password = "";

// Wi-Fi or BLE connection indicators
bool connectedToWiFi = false;
bool connectedToBLE = false;

// Server URL
const char* server = "34.230.176.208"; // Server URL

volatile int stepCount = 0;
long lastStepTime = 0;
const int stepLength = 60; // Average step length in millimeters (60 cm or 0.6 meters)

// Collar ID variable
uint32_t collarID = 0;

// RGB LED Pins
const int redPin = 9;
const int greenPin = 10;
const int bluePin = 11;

// BLE connection timeout (in milliseconds)
const unsigned long bleTimeout = 400000; // 400 seconds

void setup() {
  Serial.begin(9600);
  while (!Serial); // Wait for the serial connection to establish
  
  // Set RGB LED pins as outputs
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);

  // Start with the LED colored red (initial state)
  setColor(255, 0, 0); // Red

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  // Set advertised local name and service UUID
  BLE.setLocalName("DoggoCollar");
  BLE.setAdvertisedService(batteryService); // Advertise battery service

  // Add characteristics to the services
  batteryService.addCharacteristic(batteryLevelChar);
  stepService.addCharacteristic(stepCountCharacteristic);
  distanceService.addCharacteristic(distanceCharacteristic);

  // Add services
  BLE.addService(batteryService);
  BLE.addService(stepService);
  BLE.addService(distanceService);

  // Set initial values for the characteristics
  batteryLevelChar.writeValue(0);
  stepCountCharacteristic.writeValue(stepCount);
  distanceCharacteristic.writeValue(0); // Initialize distance to 0 meters

  // Start advertising BLE
  BLE.advertise();
  Serial.println("Advertising via BLE...");

  // Initialize IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }

  // Obtain Chip ID
  for (int i = 0; i < 4; i++) {
    collarID |= ((uint32_t) *(uint8_t*)(0x0080A00C + i) << (i * 8));
  }

  Serial.print("Collar ID: ");
  Serial.println(collarID, HEX); // Print the Collar ID in hexadecimal format

  // Attempt BLE connection with timeout
  unsigned long startTime = millis();
  while (millis() - startTime < bleTimeout) {
    BLE.poll();
    Serial.println(BLE.connected());
    if (BLE.connected()) {
      Serial.println("Connected via BLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      connectedToBLE = true;
      break;
    }
  }
  
  // If BLE connection failed, try to connect to Wi-Fi
  if (!connectedToBLE) {
    Serial.println("Failed to connect via BLE. Trying Wi-Fi...");
    connectToWiFi();
  }
}

void loop() {
  BLE.poll(); // Keep polling for BLE connections
  if (BLE.connected()) {
    connectedToBLE = true;
    Serial.println("Connected via BLE.");
    // Update characteristics as needed
  } else {
    connectedToBLE = false;
    Serial.println("Disconnected from BLE.");
  }
  // Step counting and distance calculation
  if (detectStep()) {
    stepCount++;
    int distance = (stepCount * stepLength) / 100; // Calculate distance in meters

    // Update BLE characteristics (regardless of connection status)
    stepCountCharacteristic.writeValue(stepCount);
    distanceCharacteristic.writeValue(distance); // Send distance value via BLE
  }

  // Battery monitoring
  static unsigned long previousBatteryMillis = 0;
  const long batteryInterval = 2000;
  unsigned long currentMillis = millis();

  if (currentMillis - previousBatteryMillis >= batteryInterval) {
    previousBatteryMillis = currentMillis;

    int batteryLevel = analogRead(A0); // Mock battery level read
    batteryLevel = map(batteryLevel, 0, 1023, 0, 100); // Convert to percentage

    if (connectedToWiFi) {
      sendDataViaHTTP(batteryLevel, stepCount, (stepCount * stepLength) / 100, collarID);
    } else {
      batteryLevelChar.writeValue(batteryLevel);
    }

    // Debugging info
    Serial.print("Connection to Wi-Fi: ");
    Serial.println(connectedToWiFi);
    Serial.print("Connection to BLE: ");
    Serial.println(connectedToBLE);
    Serial.print("Battery Level %: ");
    Serial.println(batteryLevel);
    Serial.print("Step count: ");
    Serial.println(stepCount);
    Serial.print("Distance (m): ");
    Serial.println((stepCount * stepLength) / 100); // Print distance in meters
    Serial.println("----------------------------");
  }

  // Recheck Wi-Fi connection status periodically
  //checkWiFiConnection();

  delay(100); // Adjust delay based on your dog's step frequency
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

void sendDataViaHTTP(int battery, int steps, int distance, uint32_t collarID) {
  if (WiFi.status() == WL_CONNECTED) {
    WiFiClient client;

    if (client.connect(server, 5000)) {
      String putData = "battery=" + String(battery) + "&steps=" + String(steps) + "&distance=" + String(distance) + "&collarID=" + String(collarID, HEX);
      
      // Send HTTP request
      client.println("PUT /api/dogs/collar_data HTTP/1.1");
      client.println("Host: " + String(server));
      client.println("Content-Type: application/x-www-form-urlencoded");
      client.println("Content-Length: " + String(putData.length()));
      client.println();
      client.println(putData);

      Serial.println("HTTP PUT request sent.");

      //while (client.available()) {
      //  response += client.readStringUntil('\n');
      //}
      //Serial.println("Response: ");
      //Serial.println(response); // Print the response for debugging

    } else {
      Serial.println("Connection to server failed.");
    }
    client.stop();
  }
}

void checkWiFiConnection() {
  if (WiFi.status() == WL_CONNECTED && !connectedToWiFi) {
    connectedToWiFi = true;
    connectedToBLE = false;
    BLE.stopAdvertise(); // Stop BLE advertising if connected to Wi-Fi
    Serial.println("Connected to Wi-Fi, stopping BLE advertising.");
    setColor(0, 0, 255); // Blue (Wi-Fi connected)
  } else if (WiFi.status() != WL_CONNECTED && !connectedToBLE) {
    connectedToWiFi = false;
    connectedToBLE = true;
    BLE.advertise();
    Serial.println("Lost Wi-Fi connection, advertising via BLE.");
    setColor(0, 255, 0); // Green (BLE connected)
  }
}

void connectToWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi...");
  
  for (int i = 0; i < 10; i++) { // Try connecting for 10 seconds
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("Connected to Wi-Fi!");
      connectedToWiFi = true;
      connectedToBLE = false;
      setColor(0, 0, 255); // Blue (Wi-Fi connected)
      break;
    }
    delay(1000);
    Serial.print(".");
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Failed to connect to Wi-Fi.");
    connectedToWiFi = false;
    connectedToBLE = true;
    setColor(255, 0, 0); // Red (connection failed)
  }
}

void setColor(int red, int green, int blue) {
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);
}
