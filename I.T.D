//************************************LIBRARIES****************************************************
#include <WiFi.h>
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"
#include <Arduino.h>

//************************************CONSTANTS****************************************************

// WiFi parameters
#define WLAN_SSID       "MartinGR5"
#define WLAN_PASS       "29417007"

// Adafruit IO
#define AIO_SERVER      "io.adafruit.com"
#define AIO_SERVERPORT  1883
#define AIO_USERNAME    "MartinMEP"
#define AIO_KEY         "aio_aTTJ76kELZLFaJglRXoUk4brl7EQ"  // Obtained from account info on io.adafruit.com
#define SERIAL_NUMBER   5555

//************************************GLOBAL VARIABLES****************************************************

// Functions


// Create an ESP32 WiFiClient class to connect to the MQTT server.
WiFiClient client;

//Timer for ping. Ping is needed to hold the device connected to the server
unsigned long timer = 0;

// Store the MQTT server, client ID, username, and password in flash memory.
// This is required for using the Adafruit MQTT library.
const char MQTT_SERVER[]    = AIO_SERVER;
const char MQTT_CLIENTID[]  = AIO_KEY __DATE__ __TIME__;
const char MQTT_USERNAME[]  = AIO_USERNAME;
const char MQTT_PASSWORD[]  = AIO_KEY;

// Setup the MQTT client class by passing in the WiFi client and MQTT server and login details.
Adafruit_MQTT_Client mqtt(&client, MQTT_SERVER, AIO_SERVERPORT, MQTT_CLIENTID, MQTT_USERNAME, MQTT_PASSWORD);

/****************************** Feeds ***************************************/

// Notice MQTT paths for AIO follow the form: <username>/feeds/<6A>

//Subscribes
Adafruit_MQTT_Subscribe devSubscribe = Adafruit_MQTT_Subscribe(&mqtt, AIO_USERNAME "/feeds/6A");

int trigPin = 12;                                          //Vi har angivet trigPin til at være 12
int echoPin = 13;                                          //Vi har angivet echoPin til at være 13
int pingTravelTime;                                        //Vi bruger travelTime som reference til måling
int greenLed1 = 18;                                        //Vi har angivet redLed til at være 18
int blueLed2 = 26;
int greenLed2 = 33;
int greenLed3 = 25;
int redLed3 = 21;                                          //Vi har angivet greenLed til at være 19
int delaytime = 500;                                       //Her laves der en varibel for delay,så man hurtigt kan ændre.
int buzzer = 14;
bool ledbool = 0;
bool resetbool = 0;
String Student;
//Vi angiver en bool værdi på 0, bool er 0-1 (ja eller nej)


void setup() {
  //Initialize serial and wifi communication
  pinMode(trigPin, OUTPUT);                                 //Her angiver vi d12 på esp32 til at være OUTPUT
  pinMode(echoPin, INPUT);                                  //Her angiver vi d11 på esp32 til at være INPUT
  pinMode(greenLed1, OUTPUT);                               //Her angiver vi d5 på esp32 til at være OUTPUT
  pinMode(blueLed2, OUTPUT);                                //Her angiver vi d6 på esp32 til at være OUTPUT
  pinMode(redLed3, OUTPUT);                                 //Her angiver vi d7 på esp32 til at være OUTPUT
  pinMode(greenLed2, OUTPUT);
  pinMode(greenLed3, OUTPUT);

  pinMode(buzzer, OUTPUT);
  //Her vælger vi hastigheden på forbindelsen mellem pc og esp32


  Serial.begin(115200);
  delay(10);
  Serial.print(F("Connecting to "));
  Serial.println(WLAN_SSID);

  WiFi.begin(WLAN_SSID, WLAN_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(F("."));
  }
  Serial.println();

  Serial.println(F("WiFi connected"));
  Serial.println(F("IP address: "));
  Serial.println(WiFi.localIP());

  //Subscribe to other device
  mqtt.subscribe(&devSubscribe);

  // connect to adafruit io
  Serial.print(F("Connecting to Adafruit IO... "));

  int8_t ret;

  while ((ret = mqtt.connect()) != 0) {

    yield();
    switch (ret) {
      case 1: Serial.println(F("Wrong protocol")); break;
      case 2: Serial.println(F("ID rejected")); break;
      case 3: Serial.println(F("Server unavail")); break;
      case 4: Serial.println(F("Bad user/pass")); break;
      case 5: Serial.println(F("Not authed")); break;
      case 6: Serial.println(F("Failed to subscribe")); break;
      default: Serial.println(F("Connection failed")); break;
    }

    if (ret >= 0)
      mqtt.disconnect();

    Serial.println(F("Retrying connection..."));
    delay(200);

  }

  Serial.println(F("Adafruit IO Connected!"));
}

void loop() {
  digitalWrite(trigPin, LOW);                              //Her fortæller vi esp32 at d12 skal være passiv
  delayMicroseconds(10);                                   //Vi stopper vores loop i 10 milisekunder
  digitalWrite(trigPin, HIGH);                             //Her fortæller vi esp32 at d12 skal være aktiv
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  pingTravelTime = pulseIn(echoPin, HIGH);                 //Her angiver vi at pingTravelTime er en pulseIn værdi og vi måler på echoPin(d11)
  delay(25);                                               //Her pauser loop'et
  Serial.println(pingTravelTime);                          //Her får vi serila monitor til at udskrive den værdi vores ultrasoniske sensor afgiver

  // Subscribe to Adafruit MQTT-broker
  Adafruit_MQTT_Subscribe *subscription;

  if (subscription = mqtt.readSubscription(10)) {
    Serial.println("Reading published data from Adafriut IO");
    yield();
  }
  if (subscription == &devSubscribe) {

    // convert mqtt ascii payload to String
    String stringValue((char *)devSubscribe.lastread);
    Student = stringValue;
    Student.toLowerCase();

    Serial.print(F("Received: "));


    Serial.println("String: " + stringValue);
  }


  //Serial.println("debug1");
  //while (Serial.available() == 0) {}
  //Serial.println("debug2");
  // Reads a string from Serial monitor
  //Student = Serial.readString();                           // her læser den min besked som jeg har skrvet i string format og laver det jeg skriver til det nye MyName variabel

  if (Student == "martin") {                                 //Her spørger vi om "Martin" bliver sendt til vores serial monitor
    Student = "";                                            //Hvis ikke martin er at finde, så bliver den ved med at spørge
    digitalWrite(buzzer, HIGH);
    delay(400);
    digitalWrite(buzzer, LOW);
    delay(delaytime);
    digitalWrite(redLed3, HIGH);                             //Her fortæller vi at vi gerne vil have tændt vores røde led pære
    delay(delaytime);                                        //Pause i koden. Her er der lavet en variabel some hedder "delaytime" som er angivet i global scope
    digitalWrite(redLed3, LOW);                              //Her fortæller vi at vi gerne vil have vores røde led pære slukket
    delay(delaytime);
    digitalWrite(blueLed2, HIGH);
    delay(delaytime);
    digitalWrite(blueLed2, LOW);
    delay(delaytime);
    digitalWrite(greenLed1, HIGH);
    delay(delaytime);
    digitalWrite(greenLed1, LOW);
    delay(delaytime);
  }

  else if (Student == "nanna") {
    Student = "";
    digitalWrite(buzzer, HIGH);
    delay(400);
    digitalWrite(buzzer, LOW);
    delay(delaytime);
    digitalWrite(redLed3, HIGH);                            //Her fortæller vi at vi gerne vil have tændt vores røde led pære
    delay(delaytime);                                       //Pause i koden. Her er der lavet en variabel some hedder "delaytime" som er angivet i global scope
    digitalWrite(redLed3, LOW);                             //Her fortæller vi at vi gerne vil have vores røde led pære slukket
    delay(delaytime);
    digitalWrite(blueLed2, HIGH);
    delay(delaytime);
    digitalWrite(blueLed2, LOW);
    delay(delaytime);
    digitalWrite(greenLed1, HIGH);
    delay(delaytime);
    digitalWrite(greenLed1, LOW);
    delay(delaytime);
  }
  else if (Student == "david") {
    Student = "";
    digitalWrite(buzzer, HIGH);
    delay(400);
    digitalWrite(buzzer, LOW);
    delay(delaytime);
    digitalWrite(redLed3, HIGH);                            //Her fortæller vi at vi gerne vil have tændt vores røde led pære
    delay(delaytime);                                       //Pause i koden. Her er der lavet en variabel some hedder "delaytime" som er angivet i global scope
    digitalWrite(redLed3, LOW);                             //Her fortæller vi at vi gerne vil have vores røde led pære slukket
    delay(delaytime);
    digitalWrite(blueLed2, HIGH);
    delay(delaytime);
    digitalWrite(blueLed2, LOW);
    delay(delaytime);
    digitalWrite(greenLed1, HIGH);
    delay(delaytime);
    digitalWrite(greenLed1, LOW);
    delay(delaytime);
  }
  else {
    Serial.println("Unknown");                             //Hvis ingen af de tre navne er at finde, skriver der "Unknown" ud i serial monitor
  }








  if (pingTravelTime < 500) {                              //Her laver vi en kontrolsætning, der betyder at hvis vores pingTravekTime(værdi) er over 500, så udfører den koden nedenunder.
    if (ledbool == 0)                                      //Her bliver der spurgt om vores bool værdi er 0
    {
      digitalWrite(buzzer, HIGH);
      delay(400);
      digitalWrite(buzzer, LOW);
      delay(delaytime);
      digitalWrite(redLed3, HIGH);                         //Her fortæller vi at vi gerne vil have tændt vores røde led pære
      delay(delaytime);                                    //Pause i koden. Her er der lavet en variabel some hedder "delaytime" som er angivet i global scope
      digitalWrite(redLed3, LOW);                          //Her fortæller vi at vi gerne vil have vores røde led pære slukket
      delay(delaytime);
      digitalWrite(blueLed2, HIGH);
      delay(delaytime);
      digitalWrite(blueLed2, LOW);
      delay(delaytime);
      digitalWrite(greenLed1, HIGH);
      delay(delaytime);
      digitalWrite(greenLed1, LOW);
      delay(delaytime);

      digitalWrite(greenLed1, HIGH);
      digitalWrite(greenLed2, HIGH);
      digitalWrite(greenLed3, HIGH);

      ledbool = 1;                                         //Her sætter vi vores værdi til 1, så den ikke kører den samme kode igen, men hopper videre til næste del nedenunder.


    }
    else
    {
      digitalWrite(greenLed1, LOW);
      delay(200);
      digitalWrite(greenLed2, LOW);
      delay(200);
      digitalWrite(greenLed3, LOW);
      delay(200);

      ledbool = 0;                                         //Her nulstiller vi vores værdi til 0, så den starter forfra.



    }

    delay(delaytime);
    Serial.println("LED tændt");                           //Her udskriver vi "LED tændt" i serial monitor,så vi kan læse den er tændt

  }
  //else  {                                                //Denne kode kører kun hvis pingTravelTime er over værdien 500
  //digitalWrite(redLed3, LOW);                            //Her holdes led'en slukket
  //digitalWrite(blueLed2, LOW);                           //Her holdes led'en slukket
  //digitalWrite(greenLed1,LOW);                           //Her holdes led'en slukket
  Serial.println("LED slukket");                           //Her printer vi "LED slukket" i vores serial monitor, så vi kan se den er slukket


}
