#include <SoftwareSerial.h>
#include <TinyGPS.h>
#include <SD.h>

long cycle;

long lat,lon; // create variable for latitude and longitude object
unsigned long time, date;
unsigned int emf_detector;
unsigned int vis_light;
unsigned int ir_light;
String data = "";
boolean cardPresent = false;
boolean headless = false;
File dataFile;

SoftwareSerial gpsSerial(2, 3); // create gps sensor connection
TinyGPS gps; // create gps object

void setup()
{
  if(!headless)
  {
    Serial.begin(9600); // connect serial
  }
  pinMode(10, OUTPUT);
  gpsSerial.begin(4800); // connect gps sensor
  cycle = 0;
  data = "";
  emf_detector = 0;
  vis_light = 0;
  ir_light = 0;
  if(SD.begin(10))
  {
    cardPresent = true;
    writeToCard("start");
  }
}

void loop()
{
  if(cycle == 250)
  {
    while(gpsSerial.available())
    {
      if(gps.encode(gpsSerial.read()))
      { 
        gps.get_position(&lat,&lon); //get latitude and longitude
        gps.get_datetime(&date, &time); //get date and time

          data = "";
        data += lat;
        data += ",";
        data += lon;
        data += ",";
        data += date;
        data += ",";
        data += time;
        data += ",";
        data += emf_detector;
        data += ",";
        data += vis_light;
        data += ",";
        data += ir_light;
        data += ".";

        if(!headless)
        {
          Serial.println(data);
        }
        if(cardPresent)
        {
          if(!writeToCard(data))
          {
            if(!headless)
            {
              Serial.println("Fail.");
            }
          }
          else
          {
            digitalWrite(7, HIGH);
            delay(100);
            digitalWrite(7, LOW);
          }
        }
        else
        {
          if(!headless)
          {
            Serial.println("No card.");
          }
        }
      }
    }
    cycle = 0;

    //read emf sensor on line 0
    int emf_total = 0;
    int a0_value = 0;
    for(int emf_c=0; emf_c < 5; emf_c++)
    {
      a0_value = analogRead(A0);
      emf_total = emf_total + a0_value;
      delay(10);
    }
    emf_detector = (int)(emf_total / 5);
    
    //read visible light
    vis_light = analogRead(A2);
    
    //read infared light
    ir_light = analogRead(A3);
  }
  cycle++;
}

boolean writeToCard(String stringToWrite)
{
  dataFile = SD.open("datalog.txt", FILE_WRITE);
  if (dataFile) 
  {
    dataFile.println(stringToWrite);
    dataFile.close();
    return true;
  }
  return false;
}





















