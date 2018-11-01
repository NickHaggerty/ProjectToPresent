int numDataPoints = 50000;
int dataIndex = 1;
String[] dataStrings = new String[numDataPoints]; // Save up to 10k values

double fps = 60;

// loads a library needed to establish a connection to a serial device
// in our case, the serial device is a Circuit Playground
import processing.serial.*;   

// create a new array that will hold on to the sensor values
// from the Circuit Playground
float[] portValues = new float[8];

// create a new serial connection
Serial myPort;

// Create a string that will hold onto all the sensor values
// we will take this string and break it up into 8 parts in 
// other parts of the code
String inString;  

float a = 30;


void setup() {
   size(640, 640);
  noStroke();
  
  
  myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600);
  // fill up the portValues array with zeros
  // we do this at the beginning so that we don't have
  // any runtime errors if the circuit playground doesn't work
  // right away.
  for(int i = 0; i<8; i++)
  {
    portValues[i] = 0; 
  }
  dataStrings[0] = "x,y,z,leftButton,rightButton,lightSensor,soundSensor,tempSensor";

  
} 
 


 // convert float data to string data in order to save to a file
String buildDataString(float[] v) {
  String result = "";
  for(int i = 0; i<v.length-1; i++) {
   result += str(v[i]) + ","; 
  }
  result += str(v[7]);
  return result;
}


void draw() {
  
  
  
  // this if statement makes sure that Processing is actually
   // reading data from the Circuit Playground BEFORE it runs the function
   // processSensorValues()  
  if (inString != null) {
    portValues = processSensorValues(inString); // get data
    // manage data points
    dataIndex++;
    if(dataIndex > numDataPoints - 1) {
     dataIndex = 1; 
    }
    dataStrings[dataIndex] = buildDataString(portValues);
    saveStrings("values.csv",dataStrings);
  }
  
  //the color of the dot's
  fill(0, 255, portValues[5]);
  //makes it that left button adds fps, right button subtracts fps.
  if(portValues[3] == 1){
   fps += 0.3;
  } else if(portValues[4] == 1){
   fps -= 0.3; 
  }
  if(fps < 1)
  fps = 1;
  //framerate of the program
  frameRate((int)fps);
  
  
  //color of the background
  background(0 , 0 , ((portValues[7] - 85) * 25) );
  //sets 0,0 to almost centre of the screen.
  translate(width/2-25, height/2);
  //makes the balls 
  for (int i = 0; i < 360; i+=a) {
    for(int q = -36; q < 36; q++){
      float x = i/(a/6)+tan(radians(dist(i/(a/2), i/(a/2), 0, 0)+q*50+frameCount))*a;
      ellipse(x, q*10, 5, 5); 
    }
  }
  //makes sure the sensor is outputting values
    println(portValues[1]+ " " + portValues[2] + " " + portValues[3] + " " + portValues[4]);
    println(portValues[5]+ " " + portValues[6]+ " " + portValues[7]+ " " + fps);
}

//  this code gets data from the Circuit Playground
// and packages it up inside of an array.  You can go 
// here to learn more about arrays in Processing: 
// https://processing.org/reference/Array.html
//
// There is some error checking here to make sure the 
// Circuit Playground is reporting values
// the code is still a bit buggy.  If you have any errors
// in lines 138 - 164, just press stop and try again.
float[] processSensorValues(String valString) {
  
  String[] temp = {"0", "0", "0", "0", "0", "0", "0", "0"};
  
  temp = split(valString,"\t");
  
  if(temp == null) {
    for(int i = 0; i<8; i++) {
      temp[i] = "0"; 
    }
  }
  
  float[] vals = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  for(int i = 0; i<8; i++)
  {
    if(temp != null) 
    {
      vals[i] = float(temp[i]); 
    }
    
    else
    {
      vals[i] = 0; 
    }
    
  }
  return vals;
}

// read new data from the Circuit Playground
void serialEvent(Serial p) { 
  inString = myPort.readStringUntil(10);  
} 
