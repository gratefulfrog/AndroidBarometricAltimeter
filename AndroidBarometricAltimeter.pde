/* runs on emulator and nexus 4
 * but ketai.jar must be added to the data directory!
 * and never forget fullScreen() in setup!  
 */

import ketai.sensors.*;
import ketai.ui.*;
import android.view.MotionEvent;

KetaiGesture gesture;
KetaiSensor sensor;
float pressure,
      pressureRef,
      altRef;
      
String altText ="";

boolean altOk = false,
        pressureOk =  false;

final float mbar2Meter = 7.88801;

final int timeOut = 3000;

public void settings(){
  fullScreen();
  orientation(PORTRAIT);
}

void setup(){
  gesture = new KetaiGesture(this);
  sensor = new KetaiSensor(this);
  sensor.start();
  sensor.list();
  textAlign(CENTER, CENTER);
  textSize(48);
  frameRate(60);
  while (!pressureOk);
  doAltRef();
}

void doAltRef(){
   KetaiKeyboard.show(this);
}
   
void draw(){
  background(0);
  if (altOk){
    textSize(48);
    text( "Altitude (m) : " + pressure2Altitude(pressure) + "\n\n"
        + "Difference (m) : " + round(pressure2Altitude(pressure)-altRef) + "\n\n"
        + "Pressure (mBar) : " + round(pressure)
      ,width/2.0, height/2.0);
  }
  else{
    textSize(48);
    text("Enter Current Altitiude (m) :\n" + altText
      ,width/2.0, height/3.0);
    textSize(24);
    text("Double tap any time\nto reset altitude\n" 
        +  "Single tap to stop measurement"
      ,width/2.0, height/3.0 + 100);
  }
}


void onPressureEvent(float p, long timeStamp, int accuracy){ //: p ambient pressure in hPa or mbar
  pressure = p;
  pressureOk = true;
}

int pressure2Altitude(float p){
  return round(altRef + (pressureRef-p)* mbar2Meter);
}

public void mousePressed() { 
  if (sensor.isStarted())
    sensor.stop(); 
  else
    sensor.start(); 
  //println("KetaiSensor isStarted: " + sensor.isStarted());
}

void onDoubleTap(float x, float y){
  frameRate(60);
  altOk = false;
  pressureOk =  false;
  altText="";
  doAltRef();
}

void keyPressed() {
  if (key != CODED && key != ENTER) {
  altText += key;
  }
  if (key == ENTER){
    altRef = Integer.valueOf(altText);
    pressureRef = pressure;
    altOk = true;
    KetaiKeyboard.toggle(this);
    frameRate(1);
  } 
}

public boolean surfaceTouchEvent(MotionEvent event) {
  //call to keep mouseX and mouseY constants updated
  super.surfaceTouchEvent(event);
  //forward events
  return gesture.surfaceTouchEvent(event);
}