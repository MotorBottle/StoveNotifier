#include <WiFi.h>
#include <PubSubClient.h>

// Replace with your network credentials
const char* ssid = "CORE";
const char* password = "crqcrqcrq";
const char* mqtt_server = "43.142.153.199";

#define SPEAKER 5

WiFiClient espClient1;
PubSubClient client(espClient1);


void setup() {
  Serial.begin(115200);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(2500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  // Connect to MQTT server
  client.setServer(mqtt_server, 18883);
  client.setCallback(callback);
  while (!client.connected()) {
    if (client.connect("espClient1")) {
      Serial.println("Connected to MQTT server");
      client.subscribe("espClient/motion");
    } else {
      delay(1000);
      Serial.println("Trying to connect to MQTT server...");
    }
  }
  
  pinMode(SPEAKER, OUTPUT);
}

void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  if (message == "ON") {
    Serial.println("Alarm!!!");
    digitalWrite(SPEAKER, HIGH);
    tone(SPEAKER, 1000, 2000);
    digitalWrite(SPEAKER, LOW);
    delay(800);
    digitalWrite(SPEAKER, HIGH);
    tone(SPEAKER, 1000, 2000);
    digitalWrite(SPEAKER, LOW);
  }
}


void loop() {
  // handle incoming MQTT messages
  client.loop();
}
