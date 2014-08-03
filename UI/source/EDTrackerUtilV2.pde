// V2.0 
// 2.0 20/07/2014 Big rewrite.
// 2.1 03/08/2014 Fix 'save calib'  reducing yaw scale by 1


String  infoString = "EDTrackerUI V2.1";

import javax.swing.JFrame;

PFrame f;
secondApplet s;

import edtracker.library.*;
EDTrackerLibrary ED;

PImage bg;

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.geom.*; 
import toxi.processing.*;
import processing.serial.*;

import controlP5.*;

ControlP5 cp5;

TriangleMesh mesh;
ToxiclibsSupport gfx;

float rad2deg = 57.29578;
float deg2rad = 1.0/rad2deg;
float rad2FSR = 10430.06;

float maxGX, maxGY, maxGZ;
float maxAX, maxAY, maxAZ;
float heading=999;

float pitchScale=0.0;
float yawScale=0.0;
String  orientation="Unknown";
String   scaleMode="Unknown";

String info = "Unknown Device";

String []messages = {
  "", "", "", "", "", "", "", "", "", ""
};

float temperature;

//float headScale = 1.0;
Serial  arduinoPort; // Usually the last port 
long    lastPing = 0;
int     portNumber = 2;
String  portName ;
String  buffer;      //String for testing serial communication

float DMPRoll, DMPPitch, DMPYaw;

boolean expScaleMode = false;// false for linear
float scaleFactor=1.0;

int  rawGyroX, rawGyroY, rawGyroZ;
int  rawAccelX, rawAccelY, rawAccelZ;

float driftScale = 10.0;
float yawDrift =0.0;
float pitchDrift =0.0;
boolean monitoring = false;
boolean fineAdj=false;

float  yawDriftComp=0.0;

boolean driftComp = false;

int adjustX    = 1;
int adjustY    = 1;
int adjustZ    = 1;


float[] yawHist      = new float [500];
float[] pitchHist    = new float [500];
float[] yawDriftHist = new float [500];
float[] tempHist     = new float [500];


int gBiasX, gBiasY, gBiasZ;
int aBiasX, aBiasY, aBiasZ;

int hs = 500;

long lastPress=0;
PFont mono;

iLowPass lpX, lpY, lpZ;

iLowPass aX, aY, aZ;
iLowPass gX, gY, gZ;

fLowPass magLP;
boolean found = false;

Textarea consoleTextArea;
Println console;

Button bMonitor;
Button bGetInfo;
Button bResetView;
Button bMount;
Button bResponse;
Button bScale;
Button bSave;
Button bCalcBias;
Button bFactReset;
Button bQuit;
Button bSketchList;
Button bRescanPorts;
Button bUploadSketch;

//Gyro Bias Nudge
Button bGXP;
Button bGXM;
Button bGYP;
Button bGYM;
Button bGZP;
Button bGZM;

//Accel Bias Nudge
Button bAXP;
Button bAXM;
Button bAYP;
Button bAYM;
Button bAZP;
Button bAZM;


//Yaw Scale Nudge
Button bYSP;
Button bYSM;
Button bPSP;
Button bPSM;



CheckBox fineCheckBox;



DropdownList sketchList;

int lastPort =0;
long lastSerialEvent=0;
int lastAttempt=0;
boolean buttonsActive = false;

ArrayList<String> sketchString;
ArrayList<String> sketchName;
ArrayList<String> sketchMajor;
ArrayList<String> sketchMinor;
ArrayList<String> sketchPatch;
ArrayList<String> sketchInfo;


void setup() {
  size(1024, 768, P3D);

  bg = loadImage("spacebox.jpg");


  cp5 = new ControlP5(this);
  ED = new EDTrackerLibrary(this);

  PFont  fp = createFont("Arial", 16);  //MS Sans Serif

  //PFont fp = loadFont("CourierNewPSMT-24.vlw");

  cp5.setControlFont(fp);
  noStroke();

  int bWidth = 260;

  bResetView = cp5.addButton("bResetView").setValue(0).setPosition(10, 140).setSize(bWidth, 28).setLabel("Reset View & Drift Tracking");
  bSave = cp5.addButton("bSave").setValue(0).setPosition(10, 170).setSize(bWidth, 28).setLabel("Save Drift Compensation");

  bMount = cp5.addButton("bMount").setValue(0).setPosition(10, 230).setSize(bWidth, 28).setLabel("Rotate Mounting Axis");
  bResponse = cp5.addButton("bResponse").setValue(0).setPosition(10, 290).setSize(bWidth, 28).setLabel("Toggle Response Mode");

  //  yawScale   =  cp5.addSlider("yawSlider").setPosition(width-300, 550).setSize(180, 20).setRange(0.0, 20.0)
  //    .setNumberOfTickMarks(81).setSliderMode(Slider.FLEXIBLE).setLabel("Yaw Scale"); 
  //
  //  pitchScale =  cp5.addSlider("pitchSlider").setPosition(width-300, 580).setSize(180, 20).setRange(0.0, 20.0)
  //    .setNumberOfTickMarks(21).setSliderMode(Slider.FLEXIBLE).setLabel("Pitch Scale"); 



  bScale = cp5.addButton("bScale").setValue(0).setPosition(10, 440).setSize(bWidth, 28).setLabel("Adjust Drift Graph Scale");

  //bSketchList= cp5.addButton("bSketchList").setValue(0).setPosition(10, 420).setSize(bWidth, 28).setLabel("List Sketches");

  bRescanPorts = cp5.addButton("bRescanPorts").setValue(0).setPosition(10, 510).setSize(bWidth, 28).setLabel("Rescan For Device");
  bGetInfo = cp5.addButton("bGetInfo").setValue(0).setPosition(10, 540).setSize(bWidth, 28).setLabel("Get Tracker Info");
  bMonitor= cp5.addButton("bMonitor").setValue(0).setPosition(10, 570).setSize(bWidth, 28).setLabel("Toggle Monitoring");






  bQuit = cp5.addButton("bQuit").setValue(0).setPosition(10, 630).setSize(bWidth, 28).setLabel("Quit");
  bFactReset = cp5.addButton("bFactReset").setValue(0).setPosition(width-300, 630).setSize(bWidth, 28).setLabel("Wipe Tracker Settings");


  bUploadSketch = cp5.addButton("bUploadSketch").setValue(0).setPosition( 240, 80).setSize(70, 28).setLabel("Flash");

  sketchList = cp5.addDropdownList("Sketch List").setPosition(10, 110).setSize(220, 200);
  sketchList.setBackgroundColor(color(190));
  sketchList.setItemHeight(30);
  sketchList.setBarHeight(28);
  sketchList.captionLabel().set("Sketch List");
  sketchList.captionLabel().style().marginTop = 3;
  sketchList.captionLabel().style().marginLeft = 3;
  sketchList.valueLabel().style().marginTop = 3;
  sketchList.setColorBackground(color(60));
  sketchList.setColorActive(color(255, 128));
  sketchList.toUpperCase(false);

  //Gyro adjustment
  bUploadSketch = cp5.addButton("bUploadSketch").setValue(0).setPosition( 240, 80).setSize(70, 28).setLabel("Flash");
  //Gyro Bias Nudge
  bGXP= cp5.addButton("bGXP").setValue(0).setPosition( width-290, 27).setSize(20, 15).setLabel("+");
  bGXM= cp5.addButton("bGXM").setValue(0).setPosition( width-265, 27).setSize(20, 15).setLabel("-");
  bGYP= cp5.addButton("bGYP").setValue(0).setPosition( width-290, 47).setSize(20, 15).setLabel("+");
  bGYM= cp5.addButton("bGYM").setValue(0).setPosition( width-265, 47).setSize(20, 15).setLabel("-");
  bGZP= cp5.addButton("bGZP").setValue(0).setPosition( width-290, 67).setSize(20, 15).setLabel("+");
  bGZM= cp5.addButton("bGZM").setValue(0).setPosition( width-265, 67).setSize(20, 15).setLabel("-");
  //
  ////Accel Bias Nudge
  bAXP= cp5.addButton("bAXP").setValue(0).setPosition( width-290, 87).setSize(20, 15).setLabel("+");
  bAXM= cp5.addButton("bAXM").setValue(0).setPosition( width-265, 87).setSize(20, 15).setLabel("-");
  bAYP= cp5.addButton("bAYP").setValue(0).setPosition( width-290, 107).setSize(20, 15).setLabel("+");
  bAYM= cp5.addButton("bAYM").setValue(0).setPosition( width-265, 107).setSize(20, 15).setLabel("-");
  bAZP= cp5.addButton("bAZP").setValue(0).setPosition( width-290, 127).setSize(20, 15).setLabel("+");
  bAZM= cp5.addButton("bAZM").setValue(0).setPosition( width-265, 127).setSize(20, 15).setLabel("-");
  //  

  bCalcBias = cp5.addButton("bCalcBias").setValue(0).setPosition(width-290, 147).setSize(bWidth, 28).setLabel("Calculate Bias Values");


  bYSP=cp5.addButton("bYSP").setValue(0).setPosition( width-290, 508).setSize(20, 15).setLabel("+");
  bYSM=cp5.addButton("bYSM").setValue(0).setPosition( width-265, 508).setSize(20, 15).setLabel("-");
  bPSP=cp5.addButton("bPSP").setValue(0).setPosition( width-290, 528).setSize(20, 15).setLabel("+");
  bPSM=cp5.addButton("bPSM").setValue(0).setPosition( width-265, 528).setSize(20, 15).setLabel("-");

fineCheckBox = cp5.addCheckBox("fineCheckBox")
                .setPosition(width-290, 550)
                .setColorForeground(color(120))
                .setColorActive(color(255,0,0))
                .setSize(20, 20)
                .addItem("Fine", 0);

  /*
   text("x Set X Accel Bias Only", 10, 320);
   text("y Set Y Accel Bias Only", 10, 340);
   text("z Set Z Accel Bias Only", 10, 380);
   text("a Set All Accel Biases", 10, 400);
   */

  f = new PFrame();

  // The font "AndaleMono-48.vlw"" must be located in the 
  // current sketch's "data" directory to load successfully

  //mono =  createFont("Courier New", 64, false);
  //mono = loadFont("Eureka-48.vlw");
  //mono = loadFont("CourierNewPSMT-24.vlw");

  background(250);
  //textFont(mono);

  maxGX= maxGY= maxGZ =0.0;
  maxAX= maxAY= maxAZ =0.0;

  frameRate(60);
  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("head3.stl"), STLReader.TRIANGLEMESH);
  //mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("mesh-flipped.stl"),STLReader.TRIANGLEMESH).flipYAxis();

  mesh.computeFaceNormals();
  mesh.computeVertexNormals();
  Vec3D forward = new Vec3D (0.0, 1.0, 0.0); 
  mesh.scale(2.0);
  mesh.pointTowards(forward);
  mesh.rotateZ(3.1415926);
  gfx=new ToxiclibsSupport(this);

  f.setText("Scan for ED Tracker...");

  lastPort = Serial.list().length -1;

  while (lastPort<0)
  {
    f.setText("No com ports in use. Rescanning...");
    delay(1000);
    lastPort = Serial.list().length -1;
  }

  f.setText("Locating ED Tracker...");


  buttonsActive =true;
  sketchString = new ArrayList<String>();
  sketchName = new ArrayList<String>();
  sketchMajor = new ArrayList<String>();
  sketchMinor = new ArrayList<String>();
  sketchPatch = new ArrayList<String>();
  sketchInfo = new ArrayList<String>();
  bSketchList(0);
  buttonsActive =false;

  //  for (int i=0;i<sketchName.size()-1;i++) {
  //    sketchList.addItem(sketchString.get(i),i);
  //  }

  //println(Serial.list());

  //scanPort(lastPort);

  ellipseMode(CENTER);

  lpX = new iLowPass(60);  //The argument is the FIFO queue length
  lpY = new iLowPass(60);  
  lpZ = new iLowPass(60);  

  aX = new iLowPass(60);
  aY = new iLowPass(60);
  aZ = new iLowPass(60);

  gX = new iLowPass(60);
  gY = new iLowPass(60);
  gZ = new iLowPass(60);

  magLP = new fLowPass(60);
}



void serialEvent(Serial p) {

  String dataIn = (arduinoPort.readString());
  char c = dataIn.charAt(0);

  //println(dataIn);
  monitoring = true;// if we're getting data

  lastSerialEvent = millis();

  try 
  {
    if (c == 'S')
    {
      monitoring = false;
    } 
    else if (c =='H')
    {
      found=true;
      arduinoPort.clear();
      arduinoPort.write('V');
      delay(300);
      //f.hide();
      arduinoPort.write('I');
      f.setText("Connected");
      delay(100);
    } 
    else if (c =='a')
    {
      adjustX = adjustY=adjustZ= 1;
    } 
    else if (c=='x')
    {
      adjustX = 1;
      adjustY=adjustZ= 0;
    } 
    else if (c=='y')
    {
      adjustY = 1;
      adjustX=adjustZ= 0;
    } 
    else if (c=='z')
    {
      adjustX = adjustY=0;
      adjustZ= 1;
    } 
    else if (c == 'V')
    {
      monitoring = true;
    } 
    else
    {
      String data[] = split(dataIn, '\t');

      if (data[0].equals ("M"))
      {
        //for (int i = 0;i<9;i++)
        //          messages[i] = messages [i+1];
        //        messages[9] = data[1];
        f.setText(data[1]);
      } 
//      else  if (data[0].equals("s"))
//      {
//        expScaleMode =  (int(data[1]) == 1);
//        scaleFactor = float(data[2]);
//      } 
       else if (data[0].equals("s"))
      {
        expScaleMode =  (int(data[1]) == 1);
        yawScale   =  float(data[2]);
        pitchScale =  float(data[3]);
      } 
      else  if (data[0].equals("I"))
      {
        println("Info "+ data[0]);
        info =  new String(data[1].substring(0, data[1].length()-2));
      } 
      else  if (data[0].equals("D"))
      {
        //println("Info");
        yawDrift = float(data[1]);
        yawDriftComp = float(data[2]);
        for (int i=0; i<hs-1;i++)
        {
          yawDriftHist[i] = yawDriftHist[i+1];
        }
        yawDriftHist[hs-1]=yawDrift;
      } 
      else  if (data[0].equals("T"))
      {
        //println(data[1]);
        temperature  = float(data[1])/32767.0;
        for (int i=0; i<hs-1;i++)
        {
          tempHist[i] = tempHist[i+1];
        }
        tempHist[hs-1]=temperature;
      } 
      else  if (data[0].equals("O"))
      {
        switch (int(data[1].trim())) {
        case 0:
          orientation = "Top/USB Right";
          break;
        case 1:
          orientation = "Top/USB Front";
          break;
        case 2:
          orientation = "Top/USB Left";
          break;
        case 3:
          orientation = "Top/USB Rear";
          break;
        case 4:
          orientation = "Left Side/USB Down";
          break;
        default:
          orientation = "Right Side/USB Down";
          break;
        }

        println("Orientation: USB Port "+ orientation);
      }
      else  if (data[0].equals("R"))
      {
        println("Recentered");
        yawDrift=0.0;
        pitchDrift=0.0;
      } 
      else if (data[0].equals("S"))
      {
        println("Silent");
        monitoring = false;
      } 
      else if (data[0].equals("B"))
      {

        gBiasX = int(data[1].trim()); 
        gBiasY = int(data[2].trim());
        gBiasZ = int(data[3].trim());
        aBiasX = int(data[4].trim());
        aBiasY = int(data[5].trim());
        aBiasZ = int(data[6].trim());
      } 
      else if (data[0].equals("V"))
      {
        println("Verbose");
        monitoring = true;
      } 
      else {
        //println("YPR");
        DMPYaw = float(data[0])/10430.06;
        DMPPitch = float(data[1])/10430.06;
        DMPRoll  = -float(data[2])/10430.06;

        //        rawAccelX = int(data[3]);
        //        rawAccelY = int(data[4]);
        //        rawAccelZ = int(data[5]);
        lpX.input (int(data[3]));
        lpY.input (int(data[4]));
        lpZ.input (int(data[5]));

        rawAccelX = lpX.output;
        rawAccelY = lpY.output;
        rawAccelZ = lpZ.output;


        gX.input (int(data[6]));
        gY.input (int(data[7]));
        gZ.input (int(data[8]));

        rawGyroX = gX.output;
        rawGyroY = gY.output;
        rawGyroZ = gZ.output;

        magLP.input(float(data[9]));
        //heading =float(data[9]);// magLP.output;
        heading =magLP.output;

        //        if (abs(rawAccelX) > maxAX)    maxAX = abs(rawAccelX) ;
        //        if (abs(rawAccelY) > maxAY)    maxAY = abs(rawAccelY) ;
        //        if (abs(rawAccelZ) > maxAZ)    maxAZ = abs(rawAccelZ) ;
        //        
        //        if (abs(rawGyroX) > maxGX)    maxGX = abs(rawGyroX) ;
        //        if (abs(rawGyroY) > maxGY)    maxGY = abs(rawGyroY) ;
        //        if (abs(rawGyroZ) > maxGZ)    maxGZ = abs(rawGyroZ) ;

        //println("A "+maxAX+" "+maxAY+" "+maxAZ+"   G "+maxGX+" "+maxGY+" "+maxGZ);
      }
    }
  } 
  catch (Exception e) {
    //    println("Caught Exception");
    //    println(dataIn);
    //  println(e);
  }
}



void draw() {

  long now = millis();

  if (!found)
  {
    if (now > lastPing)
    {
      scanPort();
      lastPing = now + 1000;
    }
  }
  else
  {// has ardi gone quiet!
    if (lastSerialEvent+10000 < millis())
    {
      f.setText("No data recieved from device.");
      disconnectPort();
      found = false;
    }
  }
  buttonsActive = true;
  pushMatrix();


  //background(90);
  background(bg);

  fill(0, 0, 0);
  rect(0, height-100, width, height);


  fill(255, 255, 255);
  textSize(26); 
  text("ED Tracker Configuration and Calibration Utility", 10, 30);


  if (monitoring)
  {
    text(info + " - Monitoring", 10, 60);
  } 
  else
  {
    fill(250, 50, 50);
    text(info +  " - Not Monitoring", 10, 60);
  }

  fill(249, 250, 150);
  textSize(18); 
  //  text("1 Toggle Monitoring", 10, 100);
  //  text("2 Get Info", 10, 120);


  if (!info.equals("Unknown Device"))
  {
    if (info.indexOf("Calib")>0)
    {
      bResetView.setVisible(false);
      bMount.setVisible(false);
      bResponse.setVisible(false);
      bScale.setVisible(false);
      bSave.setVisible(false);
      
      bYSP.setVisible(false);
      bYSM.setVisible(false);
      bPSP.setVisible(false);
      bPSM.setVisible(false);
      fineCheckBox.setVisible(false);

      bCalcBias.setVisible(true);
      bFactReset.setVisible(true);
      bRescanPorts.setVisible(true);

      bGXP.setVisible(true);
      bGXM.setVisible(true);
      bGYP.setVisible(true);
      bGYM.setVisible(true);
      bGZP.setVisible(true);
      bGZM.setVisible(true);

      bAXP.setVisible(true);
      bAXM.setVisible(true);
      bAYP.setVisible(true);
      bAYM.setVisible(true);
      bAZP.setVisible(true);
      bAZM.setVisible(true);
    } 
    else
    {
      //      text("9 Recalc Bias Values", 10, 280);
      //      text("0 Reset to Factory Bias", 10, 300);
      //      
      //      text("x Set X Accel Bias Only", 10, 320);
      //      text("y Set Y Accel Bias Only", 10, 340);
      //      text("z Set Z Accel Bias Only", 10, 380);
      //      text("a Set All Accel Biases", 10, 400);

      bResetView.setVisible(true);
      bMount.setVisible(true);
      bResponse.setVisible(true);
      bScale.setVisible(true);
      bSave.setVisible(true);

      bCalcBias.setVisible(false);
      bFactReset.setVisible(false);
      bRescanPorts.setVisible(true);
      
      bYSP.setVisible(true);
      bYSM.setVisible(true);
      bPSP.setVisible(true);
      bPSM.setVisible(true);
      fineCheckBox.setVisible(true);


      bGXP.setVisible(false);
      bGXM.setVisible(false);
      bGYP.setVisible(false);
      bGYM.setVisible(false);
      bGZP.setVisible(false);
      bGZM.setVisible(false);

      bAXP.setVisible(false);
      bAXM.setVisible(false);
      bAYP.setVisible(false);
      bAYM.setVisible(false);
      bAZP.setVisible(false);
      bAZM.setVisible(false);
    }
  }
  else
  {
    bResetView.setVisible(false);
    bMount.setVisible(false);
    bResponse.setVisible(false);
    bScale.setVisible(false);
    bSave.setVisible(false);

    bCalcBias.setVisible(false);
    bFactReset.setVisible(false);
    bRescanPorts.setVisible(true);


    bGXP.setVisible(false);
    bGXM.setVisible(false);
    bGYP.setVisible(false);
    bGYM.setVisible(false);
    bGZP.setVisible(false);
    bGZM.setVisible(false);

    bAXP.setVisible(false);
    bAXM.setVisible(false);
    bAYP.setVisible(false);
    bAYM.setVisible(false);
    bAZP.setVisible(false);
    bAZM.setVisible(false);
  }



  fill(255, 255, 150);


  if (info.indexOf("Calib")<0)
  {
    text("DMP Yaw", (int)width-240, 120);
    text("DMP Pitch", (int)width-240, 100); 
    text("DMP Roll", (int)width-240, 140);
    text("Heading", (int)width-240, 160);

    textAlign(RIGHT);

    text (nf(DMPYaw*rad2deg, 0, 2), (int)width-60, 120);
    text (nf(DMPPitch*rad2deg, 0, 2), (int)width-60, 100);
    text (nf(DMPRoll*rad2deg, 0, 2), (int)width-60, 140);
    text (nf(heading*rad2deg, 0, 2), (int)width-60, 160);
    textAlign(LEFT);
  } 
  else
  {
    if (adjustX == 1 && adjustY ==1 && adjustZ ==1)
      fill(255, 255, 250);   
    else
      fill(100, 100, 100);   

    textAlign(RIGHT);

    text (gBiasX, (int)width-300, 40);
    text (gBiasY, (int)width-300, 60);
    text (gBiasZ, (int)width-300, 80);
    text (aBiasX, (int)width-300, 100);
    text (aBiasY, (int)width-300, 120);
    text (aBiasZ, (int)width-300, 140);
    textAlign(LEFT);

    text("Raw X Gyro", (int)width-240, 40);
    text("Raw Y Gyro", (int)width-240, 60);
    text("Raw Z Gyro", (int)width-240, 80);

    textAlign(RIGHT);

    text (rawGyroX, (int)width-100, 40); 
    text (rawGyroY, (int)width-100, 60);
    text (rawGyroZ, (int)width-100, 80);
    textAlign(LEFT);


    fill(100+155*adjustX, 100+155*adjustX, 100+155*adjustX);   
    text("Raw X Accel", (int)width-240, 100);

    fill(100+155*adjustY, 100+155*adjustY, 100+155*adjustY);
    text("Raw Y Accel", (int)width-240, 120);

    fill(100+155*adjustZ, 100+155*adjustZ, 100+155*adjustZ);
    text("Raw Z Accel", (int)width-240, 140);

    text (rawAccelX/10, (int)width-100, 100); 
    text (rawAccelY/10, (int)width-100, 120);
    text ((rawAccelZ-16380)/10, (int)width-100, 140);
  }


  fill(255, 255, 160);



  //text("Yaw Offset", (int)width-240, 440);
  //text (nfp(yawOffset*rad2deg, 0, 2), (int)width-100, 440);
  //text("Pitch Offset", (int)width-240, 460);
  //text (nfp(pitchOffset*rad2deg, 0, 2), (int)width-100, 460);


  text("Yaw Drift", (int)width-240, 400);
  text("Drift Comp", (int)width-240, 420); 
  text("Temperature", (int)width-240, 440); 

  if (info.indexOf("Calib")<0)
  {
  text("Yaw Scale", (int)width-240, 520); 
  text("Pitch Scale", (int)width-240, 540); 
  }

  textAlign(RIGHT);

  text (nf(yawDrift, 1, 2), (int)width-60, 400);
  text (nf(yawDriftComp, 0, 2), width -60, 420);
  text (nf((temperature-32.0)/1.8, 0, 2), width -60, 440);
  
  
    if (info.indexOf("Calib")<0)
  {  
  text (nf(yawScale, 0, 2), width -60, 520);
  text (nf(pitchScale, 0, 2), width -60, 540);
  }
  textAlign(LEFT);



  if (info.indexOf("Calib")<0)
  {
    //text("Orientation :", (int)30, 230);
    text(orientation, 20, 280);

    if (expScaleMode) 
      text("Exponential", 20, 340);
    else
      text("Linear", 20, 340);

    //  text("Response Scale Factor", (int)width-240, 440); 
    //  text (nfp(scaleFactor, 0, 2), width -100, 440);

    text("x" + driftScale, 20, 490);
  }



  //draw the message
  stroke(255, 255, 255);
  fill(255, 255, 255);

  textSize(14); 
  //  for (int i=0;i<10; i++)
  //    f.setText(messages[i]);
  //text (messages[i], 10, height-140+i*14);

  // text(gyrStr, (int) (width/6.0) - 40, 50);

  stroke(255, 255, 255);
  line(0, height-50, width-1, height-50);

  stroke(10, 255, 10);
  for (int i=0; i<hs-1;i++)
  {
    line(i*2, height-50-yawHist[i], (i*2)+1, height-50-yawHist[i+1]); 
    yawHist[i] = yawHist[i+1];
  }
  yawHist[hs-1]=DMPYaw *rad2deg*0.55;


  stroke(250, 10, 10);
  for (int i=0; i<hs-1;i++)
  {
    line(i*2, height-50-pitchHist[i], (i*2)+1, height-50-pitchHist[i+1]); 
    pitchHist[i] = pitchHist[i+1];
  }
  pitchHist[hs-1]=(DMPPitch)*rad2deg*0.55;    

  stroke(255, 255, 0);
  for (int i=0; i<hs-1;i++)
  {
    line(i*2, height-50-constrain(yawDriftHist[i]*driftScale, -45, 45), (i*2)+1, 
    height-50-constrain(yawDriftHist[i+1]*driftScale, -45, 45));
  }



  stroke(255, 0, 0);
  for (int i=0; i<hs-1;i++)
  {
    line(i*2, height-100-10.0*(tempHist[i]-55.0), (i*2)+1, height-100-10.0*(tempHist[i+1]-55.0));
  }

  // sprit level
  fill(0, 0, 0);
  stroke(255, 255, 255);

  ellipse(width-130, 280, 180, 180);
  ellipse(width-130, 280, 45, 45);
  ellipse(width-130, 280, 90, 90);
  ellipse(width-130, 280, 45, 45);

  //  line(580, 280, 760, 280);
  //  line(670, 190, 670, 370);

  line(width-220, 280, width-40, 280);
  line(width-130, 190, width-130, 370);

  fill(255, 255, 0);
  stroke(255, 40, 40);

  //ellipse(670 + constrain (rawAccelX/10, -90, 90), 280 -constrain(rawAccelY/20, -90, 90), 5, 5);
  ellipse(width-130 + constrain (rawAccelX/10, -90, 90), 280 -constrain(rawAccelY/20, -90, 90), 5, 5);

  fill(0, 255, 255);
  stroke(25, 255, 40);
  ellipse(width-130  + constrain (rawGyroX, -90, 90), 280 -constrain(rawGyroY/2, -90, 90), 5, 5);



  fill(255, 255, 255);
  ambientLight(80, 80, 100);
  pointLight(255, 255, 255, 1000, -2000, 1000 );
  translate(width/2, height/2-20, 100);

  rotateY(DMPYaw   );// + yawOffset);
  //rotateY(heading);
  rotateX(DMPPitch );// + pitchOffset);

  //hint(ENABLE_DEPTH_TEST);

  gfx.origin(new Vec3D(), 200);
  noStroke();
  noSmooth();
  gfx.mesh(mesh, false);
  popMatrix();
  //hint(DISABLE_DEPTH_TEST);
}


void exit() {
  println("exiting");
  try {
    arduinoPort.write("S\n");
    delay(200);  
    arduinoPort.clear();
    arduinoPort.stop();
  }
  catch (Exception e) {
    println(e);
  }
  super.exit();
}

