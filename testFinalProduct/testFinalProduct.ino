#include <Wire.h>
#include "MLX90640_I2C_Driver.h"
#include "MLX90640_API.h"
#include <WiFi.h>
#include <PubSubClient.h>

// Replace with your network credentials
const char* ssid = "CORE";
const char* password = "crqcrqcrq";
const char* mqtt_server = "43.142.153.199";

WiFiClient espClientMain;
PubSubClient client(espClientMain);

// 90640 basic definitions
const byte MLX90640_address = 0x33; //Default 7-bit unshifted address of the MLX90640
 
#define TA_SHIFT 8 //Default shift for MLX90640 in open air
 
static float mlx90640To[768];
paramsMLX90640 mlx90640;

//pin definitions
#define RGB_LED_RED 32
#define RGB_LED_GREEN 33
#define RGB_LED_BLUE 25
#define SPEAKER 5
#define MQ2D 18
#define motionSens 19

int i, j;
float T_max, T_min;    

unsigned long previousMillis = 0;
unsigned long motionMillis = 0;
unsigned long fireMillis = 0;
unsigned long currentMillis = 0;
const long interval = 30000;

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
    while (!client.connected()) {
      if (client.connect("espClientMain")) {
        Serial.println("Connected to MQTT server");
      } else {
        delay(1000);
        Serial.println("Trying to connect to MQTT server...");
      }
    }

    // Set up MLX90640
    Wire.begin(21,22);  // sda,scl
    Wire.setClock(400000); //Increase I2C clock speed to 400kHz

//    while (!Serial); //Wait for user to open terminal
    
    Serial.println("MLX90640 IR Array Example");
 
    if (isConnected() == false)
       {
        Serial.println("MLX90640 not detected at default I2C address. Please check wiring. Freezing.");
        while (1);
       }
       
    Serial.println("MLX90640 online!");
 
    //Get device parameters - We only have to do this once
    int status;
    uint16_t eeMLX90640[832];
    
    status = MLX90640_DumpEE(MLX90640_address, eeMLX90640);
  
    if (status != 0)
       Serial.println("Failed to load system parameters");
 
    status = MLX90640_ExtractParameters(eeMLX90640, &mlx90640);
  
    if (status != 0)
       {
        Serial.println("Parameter extraction failed");
        Serial.print(" status = ");
        Serial.println(status);
       }
 
    //Once params are extracted, we can release eeMLX90640 array
 
    MLX90640_I2CWrite(0x33, 0x800D, 6401);    // writes the value 1901 (HEX) = 6401 (DEC) in the register at position 0x800D to enable reading out the temperatures!!!
    // ===============================================================================================================================================================
 
    //MLX90640_SetRefreshRate(MLX90640_address, 0x00); //Set rate to 0.25Hz effective - Works
    //MLX90640_SetRefreshRate(MLX90640_address, 0x01); //Set rate to 0.5Hz effective - Works
    //MLX90640_SetRefreshRate(MLX90640_address, 0x02); //Set rate to 1Hz effective - Works
    //MLX90640_SetRefreshRate(MLX90640_address, 0x03); //Set rate to 2Hz effective - Works
    MLX90640_SetRefreshRate(MLX90640_address, 0x04); //Set rate to 4Hz effective - Works
    //MLX90640_SetRefreshRate(MLX90640_address, 0x05); //Set rate to 8Hz effective - Works at 800kHz
    //MLX90640_SetRefreshRate(MLX90640_address, 0x06); //Set rate to 16Hz effective - Works at 800kHz
    //MLX90640_SetRefreshRate(MLX90640_address, 0x07); //Set rate to 32Hz effective - fails

    //Wire.setClock(800000);  //optional


    // Define pinmodes
    pinMode(RGB_LED_RED, OUTPUT);
    pinMode(RGB_LED_GREEN, OUTPUT);
    pinMode(RGB_LED_BLUE, OUTPUT);
    pinMode(SPEAKER, OUTPUT);
    pinMode(MQ2D, INPUT);
    pinMode(motionSens, INPUT);

    Serial.println("Gas sensor warming up! 气体传感器预热");
    delay(5000); // allow the MQ-2 to warm up
}

void loop() {

  int motionSensorState = digitalRead(motionSens);
  
  if (motionSensorState == HIGH) {
    motionMillis = millis();
  }

  // Gas tetection and alarm
  // ====================================================
  
  int gasValue = digitalRead(MQ2D);
  
  if (gasValue == 0) {
    // Gas detected
    client.publish("espClient/motion", "ON");
    digitalWrite(RGB_LED_RED, HIGH);
    digitalWrite(RGB_LED_GREEN, LOW);
    digitalWrite(RGB_LED_BLUE, LOW);
    digitalWrite(SPEAKER, HIGH);
    tone(SPEAKER, 1000, 5000);
//    tone(SPEAKER, 1000);
//    delay(5000);
    digitalWrite(SPEAKER, LOW);
  }


  // check stove status by calculating max temp
  // ====================================================
    for (byte x = 0 ; x < 2 ; x++) //Read both subpages
       {
        uint16_t mlx90640Frame[834];
        int status = MLX90640_GetFrameData(MLX90640_address, mlx90640Frame);
    
        if (status < 0)
           {
            Serial.print("GetFrame Error: ");
            Serial.println(status);
           }
 
        float vdd = MLX90640_GetVdd(mlx90640Frame, &mlx90640);
        float Ta = MLX90640_GetTa(mlx90640Frame, &mlx90640);
 
        float tr = Ta - TA_SHIFT; //Reflected temperature based on the sensor ambient temperature
        float emissivity = 0.95;
 
        MLX90640_CalculateTo(mlx90640Frame, &mlx90640, emissivity, tr, mlx90640To);
       }
 
       
    // determine T_min and T_max and eliminate error pixels
    // ====================================================
 
    mlx90640To[1*32 + 21] = 0.5 * (mlx90640To[1*32 + 20] + mlx90640To[1*32 + 22]);    // eliminate the error-pixels
    mlx90640To[4*32 + 30] = 0.5 * (mlx90640To[4*32 + 29] + mlx90640To[4*32 + 31]);    // eliminate the error-pixels
    
    T_min = mlx90640To[0];
    T_max = mlx90640To[0];
 
    for (i = 1; i < 768; i++)
       {
        if((mlx90640To[i] > -41) && (mlx90640To[i] < 301))
           {
            if(mlx90640To[i] < T_min)
               {
                T_min = mlx90640To[i];
               }
 
            if(mlx90640To[i] > T_max)
               {
                T_max = mlx90640To[i];
               }
           }
        else if(i > 0)   // temperature out of range
           {
            mlx90640To[i] = mlx90640To[i-1];
           }
        else
           {
            mlx90640To[i] = mlx90640To[i+1];
           }
       }

  // check stove status by calculating max temp
  // ====================================================

  if (T_max < 85) {
    // Temperature is less than 85C, show green
    digitalWrite(RGB_LED_RED, LOW);
    digitalWrite(RGB_LED_GREEN, HIGH);
    digitalWrite(RGB_LED_BLUE, LOW);
    currentMillis = millis();
    if (currentmillis - fireMillis >= 5000) {
      previousMillis = millis();
    }
  } else if (T_max >= 85 && T_max < 301) {
    fireMillis = millis();
    // Temperature is between 85C and 300C, show yellow
    digitalWrite(RGB_LED_RED, HIGH);
    digitalWrite(RGB_LED_GREEN, HIGH);
    digitalWrite(RGB_LED_BLUE, LOW);
    if (millis() - motionMillis > 5000) {
      currentMillis = millis();
      if (currentMillis - previousMillis >= interval) {
        
        // Reset timer
        previousMillis = currentMillis;

        // Publish the message to the MQTT server
        client.publish("espClient/motion", "ON");
        
        // Local speaker plays sound and led blinks in red color
        digitalWrite(SPEAKER, HIGH);
        tone(SPEAKER, 1000, 1000);
        digitalWrite(RGB_LED_RED, HIGH);
        digitalWrite(RGB_LED_GREEN, LOW);
        digitalWrite(RGB_LED_BLUE, LOW);
        delay(100);
        digitalWrite(SPEAKER, LOW);
        digitalWrite(RGB_LED_RED, HIGH);
        digitalWrite(RGB_LED_GREEN, HIGH);
        digitalWrite(RGB_LED_BLUE, LOW);
        delay(100);
        digitalWrite(SPEAKER, HIGH);
        tone(SPEAKER, 1000, 1000);
        digitalWrite(RGB_LED_RED, HIGH);
        digitalWrite(RGB_LED_GREEN, LOW);
        digitalWrite(RGB_LED_BLUE, LOW);
        delay(100);
        digitalWrite(SPEAKER, LOW);
        digitalWrite(RGB_LED_RED, HIGH);
        digitalWrite(RGB_LED_GREEN, HIGH);
        digitalWrite(RGB_LED_BLUE, LOW);
        delay(100);
      }
    }
  } else {
      digitalWrite(RGB_LED_RED, LOW);
      digitalWrite(RGB_LED_GREEN, LOW);
      digitalWrite(RGB_LED_BLUE, HIGH);
  }

  client.publish("espClient/motion", "OFF");
  
  Serial.println(T_max);
  Serial.println(millis() - motionMillis);
}

//Returns true if the MLX90640 is detected on the I2C bus
boolean isConnected()
   {
    Wire.beginTransmission((uint8_t)MLX90640_address);
  
    if (Wire.endTransmission() != 0)
       return (false); //Sensor did not ACK
    
    return (true);
   }
