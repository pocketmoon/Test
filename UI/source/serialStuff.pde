

void popComList()
{
  
  return;
  
//  String sList[] = Serial.list();
//  comList.clear();
//  
//  int l = Serial.list().length-1;
//
//  for (int i =0  ; i <=l  ; i++) 
//  {
//    String data = sList[i];
//    comList.addItem(data,i);
//  }   
}

void disconnectPort()
{
  f.setText("Disconnect...");
  arduinoPort.clear();      
  arduinoPort.stop();
  delay(200);
}


void connectPort()
{
  f.setText("Connect...");
  arduinoPort = new Serial(this, portName, 115200);
  arduinoPort.clear();
  arduinoPort.bufferUntil(10);  
  arduinoPort.write('H');
  popComList();
}

void scanPort()
{
  if (Serial.list().length == 0)
  {
    f.setText("No COM Ports in use... ");
    return;    
  }

  popComList();


  if ( Serial.list().length < lastPort-1)
  {
    // in case we have lost a com port
    lastPort = Serial.list().length  -1;
  }
    
  
  portName = Serial.list()[lastPort];
  f.setText("Connecting to -> " + portName);
  //delay(20);

  if (lastAttempt>3)
  {
    lastAttempt=0;
    f.setText("No response from device on " + portName);
    arduinoPort.clear();      
    arduinoPort.stop();
    lastPort--;
    if (lastPort <0)
      lastPort = Serial.list().length -1;
  }

  try {
    arduinoPort = new Serial(this, portName, 115200);
    arduinoPort.clear();
    arduinoPort.bufferUntil(10);
    arduinoPort.write('H');
    f.setText("Waiting for response from device on " + portName);
  }
  catch (Exception e) {
    f.setText("Waiting for connecting to " + portName);
    lastPort--;
     if (lastPort <0)
      lastPort = Serial.list().length -1;
    println(e);
  }


  //  arduinoPort.clear();
  //  arduinoPort.write('I');
  //  delay(1000);
  //  arduinoPort.write('V');
  //
}

