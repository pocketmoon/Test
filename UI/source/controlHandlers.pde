
int selectedSketch;
String selectedSketchName = "";

String selectedPort = "";

public void bUploadSketch(int theValue) {
    
  if (!buttonsActive)
  return;
  
  if (selectedSketchName.length() < 1)
  {
     f.setText("No sketch selected!");
   return;  
  }  
  
  arduinoPort.write('S');
  delay(100);    
  disconnectPort();
  
  if (selectedPort.length() >1)
    portName = selectedPort;
  
  f.setText("=========================================");
  f.setText("About to flash " + sketchName.get(selectedSketch) + " to " + portName);
  f.setText("Please wait. This may take up to 60 seconds");
  f.setText("=========================================");
  buttonsActive = false;
  delay(5000);
  
  
  //   debug/verify/avrbootloader
  try {
   ED.flash(sketchName.get(selectedSketch), portName,false,true,false);
  }
   catch (Exception e) {
        f.setText("An Erroro Occurred. Please retry");
     f.setText(e.getMessage());
     e.printStackTrace();
     delay(5000);
  }

  
   f.setText("**** FLASHED ****");
   delay(500);

   buttonsActive = true;
   found = false;   // force reconnect

}



public void bMonitor(int theValue) {
  if (!buttonsActive)
  return;
  if (monitoring)
    arduinoPort.write("S\n");
  else
  {
    arduinoPort.write("V\n");
    arduinoPort.write("I\n");
  }
}


public void bGetInfo(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("I\n");
}

public void bResetView(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("R\n");
}

public void bMount(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("P\n");
}

public void bResponse(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("t\n");
}

public void bPoll(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("p\n");
}

public void bScale(int theValue) {
  if (!buttonsActive)
  return;
  driftScale *= 2.0;
  if (driftScale > 2000.0)
    driftScale = 1.0;
}

public void bSave(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("D\n");
  delay(100);
  arduinoPort.write("R\n");
}

public void bCalcBias(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("B\n");
}

public void bFactReset(int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("0\n");
  delay(200);
  arduinoPort.write("I\n");

}

public void bQuit(int theValue) {
  if (!buttonsActive)
  return;
  exit();
}

public void bSketchList(int theValue) {
  if (!buttonsActive)
  return;

  ArrayList<String> sList;
  sList = ED.getSketchList();
  
  sketchString.clear();
  sketchName.clear();
  sketchMajor.clear();
  sketchPatch.clear();
  sketchInfo.clear();
  
  sketchList.clear();

  for (int i = 0; i < sList.size()-1; i++) 
  {
    String data[] = split(sList.get(i), '\t');
    f.setText( data[0] + " " + "(" + data[1] +"." + data[2] + "." + data[3]+")");    
    sketchString.add(data[0] + " " + "(" + data[1] +"." + data[2] + "." + data[3]+")");
    
    sketchList.addItem(data[0] + " " + "(" + data[1] +"." + data[2] + "." + data[3]+")", i);
  
    sketchName.add(data[0]);
    sketchMajor.add(data[1]);
    sketchMinor.add(data[2]);
    sketchPatch.add(data[3]);
    sketchInfo.add(data[4]);
  }
}


void bGXP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("M\n");
}

void bGXM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("m\n");
}

void bGYP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("N\n");
}
void bGYM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("n\n");
}
void bGZP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("O\n");
}
void bGZM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("o\n");
}



void bAXP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("J\n");
}

void bAXM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("j\n");
}

void bAYP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("K\n");
}
void bAYM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("k\n");
}
void bAZP (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("L\n");
}
void bAZM (int theValue) {
  if (!buttonsActive)
  return;
  arduinoPort.write("l\n");
}




void bYSP (int theValue) {
  if (!buttonsActive)
  return;
  
  if (fineAdj)
  arduinoPort.write("c\n");
  else
  arduinoPort.write("C\n");
  
}


void bYSM (int theValue) {
  if (!buttonsActive)
  return;
  
  if (fineAdj)
  arduinoPort.write("d\n");
  else
  arduinoPort.write("G\n");
}


void bPSP (int theValue) {
  if (!buttonsActive)
  return;
  
  if (fineAdj)
  arduinoPort.write("e\n");
  else
  arduinoPort.write("E\n");
}

void bPSM (int theValue) {
  if (!buttonsActive)
  return;
  
  if (fineAdj)
  arduinoPort.write("f\n");
  else
  arduinoPort.write("F\n");
}




void bRescanPorts (int theValue) {
  if (!buttonsActive)
  return;
 
  found = false;
  disconnectPort();
  f.setText("Re-scan for ED Tracker...");
  lastPort = Serial.list().length -1;
  buttonsActive = false;
  
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.
    if (theEvent.isFrom(fineCheckBox)) 
    {            
      int n = (int)fineCheckBox.getArrayValue()[0];
      if(n==1) 
        fineAdj = true;
      else
        fineAdj = false;      
    }
    
    
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
   // println("event from group : "+(int)theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    String grp = theEvent.getGroup().getName();
    if (grp.indexOf("Sketch List") >= 0)
    {
      selectedSketch = (int)(theEvent.getGroup().getValue());
      selectedSketchName = sketchList.getItem(selectedSketch).getName();
      f.setText("Sketch selected: " +selectedSketchName);
    }else
     if (grp.indexOf("COM PORTS") >= 0)
    {
      selectedPort = comList.getItem((int)(theEvent.getGroup().getValue())).getName();
      f.setText("Port selected: " +selectedPort);
    }
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}



