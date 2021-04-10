int rows = 112;
int hexPerRow = 60;

int hue = 0;

int w = 640;
int h = 480;

float currentTime = 0.0f;
float previousTime = 0.0f;
float FRAME_LIMIT = 60.0f;
float DELTA_TIME_CAP = 0.033f;
float delta = 0.0f;

ArrayList<Hexagon> hexes = new ArrayList<Hexagon>(); //Array

//Flow
ShimodairaOpticalFlow SOF;

//used to enable working in 3D flows
boolean disabledVideo = false;

int resChange = 4;

//bool to track whether hexes have moved
boolean hexesAreStatic = false;
float staticTime = 0.0;
float staticMax = 5.0; //seconds

//enum to determine static action
enum StaticAction
{
    explode,
    twirl,
    swirl,
    blanket,
    wavy,
    none,
}

StaticAction staticAction = StaticAction.explode;
float actionTime = 0.0;

//stores overall flow movement (absolute value)
float xFlow = 0.0f;
float yFlow = 0.0f;
float flowThreshold = 300.0f; //The amount considered "no movement" in x or y direction

boolean allowFlowInfluence = true;

void setup()
{
    //size(640, 480, P3D);
    //size(960, 720, P3D);
    //size(1280, 960, P3D);
    //size(1640, 960, P3D);
    //size(960, 540, P3D);
    //size(1920, 1080, P3D);
    size(1632, 918, P3D);
    //fullScreen();
    
    pixelDensity(2);

    colorMode(HSB, 360);
    
    frameRate(30);
    smooth();
    
    // --- Creating Camera
    String[] cameras = Capture.list();

    if (cameras.length == 0) {
        println("There are no cameras available for capture. Exiting application");
        exit();
    } else {
        println("Available cameras:");
        for (int i = 0; i < cameras.length; i++) {
            println(cameras[i]);
        }
        // The camera can be initialized directly using an 
        // element from the array returned by list():
        Capture cam = new Capture(this, width/resChange, height/resChange, cameras[0]);
        
        // --- DECREASE resolution of camera
        
        cam.start();
                
        SOF = new ShimodairaOpticalFlow(cam);
    }


    // --- creating hexagons
    resetHexagons(true);

    // --- disabling video
    //SOF.flagimage=!SOF.flagimage;

    //getting last time
    previousTime = millis();
    previousTime /= 1000.0f;
}

void draw() {
    
    //deltaTime
    updateDeltaTime();

    //refreshing background
    //background(0, 0, 0, 0.001);
    fill(0, 0, 0, 100);
    rect(0,0,width,height);

    //updating the hexagons
    //updateHexagons();
    
    //does other things to the hexagons
    staticHexagonActions();

    //drawing hexes
    // also update hexes hues
    drawHexagons();

    //drawing optical flow
    drawOpticalFlow();

    //updating previousTime
    previousTime = currentTime;
    
    //disabling video for the first runthrough
    if (!disabledVideo)
    {
        //disabling image
        SOF.flagimage=!SOF.flagimage;
        
        //disabling flow
        SOF.flagflow=!SOF.flagflow;
        
        disabledVideo = true;
    }
    
    //resetting flow data
    xFlow = 0.0;
    yFlow = 0.0;
    
    //getting flow data
    for (int i = 0; i < SOF.flows.size(); i += 2)
    {
        float x = abs(SOF.flows.get(i).x - SOF.flows.get(i+1).x);
        float y = abs(SOF.flows.get(i).y - SOF.flows.get(i+1).y);
        
        xFlow += x;
        yFlow += y;
        
        //display circles over movement
        /*
        if (x + y > 20)
        {
            fill(217, 0, 360, 360);
            ellipse(SOF.flows.get(i).x * resChange, SOF.flows.get(i).y * resChange, 10, 10);
        }
        */
    }
    //println("xFlow: " + xFlow + " | yFlow: " + yFlow);
    
    
    //determining static timer
    if (xFlow <= flowThreshold && yFlow <= flowThreshold)
    {
        //adding to time
        staticTime += delta;
        
        //if time passes static max, enable a static action (as long as there is no action yet)
        if (staticTime >= staticMax && staticAction == StaticAction.none)
        {
            int r = (int)random(0,8);
            //r = 1;
            switch (r)
            {
                case 0 : staticAction = StaticAction.explode;
                    break;
                case 1 : staticAction = StaticAction.twirl;
                    break;
                case 2 : staticAction = StaticAction.swirl;
                    break;
                case 3 : staticAction = StaticAction.blanket;
                    break;
                case 4 : staticAction = StaticAction.wavy;
                    break;
                case 5 : changeHexagonColors(true); // Change all the hexagons with gradient color
                    break;
                case 6 : changeHexagonColors(false); // Change all the hexagons with solid color
                    break;
            }
            
        }
    }
    else
    {
        //setting timer back to zero
        staticTime = 0.0f;
    }
    //println("staticTime: " + staticTime);
    
}

void updateDeltaTime()
{
    //getting deltaTime
    currentTime = (float)millis();
    currentTime /= 1000.0f;
    
    //println("deltaTime: " + delta);

    //frame limiting
    while (currentTime < (previousTime + (1 / FRAME_LIMIT)))
    {
        currentTime = (float)millis();
        currentTime /= 1000.0f;
    }

    //calculating deltaTime
    delta = currentTime - previousTime;

    //capping to maximum deltaTime
    if (delta > DELTA_TIME_CAP)
    {
        delta = DELTA_TIME_CAP;
    }
}

void drawOpticalFlow()
{
    // draw image
    if (SOF.flagimage) set(0, 0, SOF.cam);
    //else background(120);

    // calculate optical flow
    SOF.calculateFlow(); 

    // draw the optical flow vectors
    if (SOF.flagflow)
        SOF.drawFlow();

    //print out the optical flow (e.g. to use them with some other system)
    for (int i = 0; i < SOF.flows.size() - 2; i+=2) {
        PVector force_start = SOF.flows.get(i);
        PVector force_end = SOF.flows.get(i+1);
        //println ("force from " + force_start + " to " + force_end);
    }
}

void updateHexagons()
{
    //starting at true
    hexesAreStatic = true;
    
    //only move hexagons with camera if no staticAction
    if (allowFlowInfluence)
    {
        for (Hexagon hex : hexes)
        {
            //checking for flow movement to influence hexagon
            
            PVector flow_vect = SOF.lookup(new PVector(hex.currentX / resChange, hex.currentY / resChange));
            hex.velocity.add(flow_vect.mult(3));
            
            //updating hexagon
            hex.updateHex();
            
            if (hex.mIsMoving)
            {
                hexesAreStatic = false;
            }
        }
    }
    else //only update hexagons
    {
        for (Hexagon hex : hexes)
        {
            //updating hexagon
            hex.updateHex();
        }
    }
}

void drawHexagons() {

    for (Hexagon hex : hexes)
    {
        //only move hexagons with camera if no staticAction
        if (allowFlowInfluence)
        {
            PVector flow_vect = SOF.lookup(new PVector(hex.currentX / resChange, hex.currentY / resChange));
            hex.velocity.add(flow_vect.mult(3));
        }
        
        //updating hexagon
        hex.updateHex();
        
        //drawing the hexagon
        hex.drawHex();        
    }


}



void keyPressed()
{

    int i = 50;

    //console.log("Hex x: " + hexes[i].currentX);

    if (keyCode == LEFT)
    {
        hexes.get(i).currentX = width/2;
        hexes.get(i).currentY = height/2;
    }
    
    //starts explosion action
    if (key == 'e')
    {
        staticAction = StaticAction.explode;
    }
    
    //disables/enables hexes from returning to their origin
    if (key == '1')
    {
        for (Hexagon hex : hexes)
        {
            hex.mReturnsToOrigin = !hex.mReturnsToOrigin;
        }
    }
    
    //resets the hexagons
    if (key=='r') resetHexagons(true); // resets all the hexagons
    if (key=='t') resetHexagons(false); // resets all the hexagons with single color
    
    //change hexagon colors
    if (key=='o') changeHexagonColors(true); // Change all the hexagons with gradient color
    if (key=='p') changeHexagonColors(false); // Change all the hexagons with single color

    //console.log("Hex new x: " + hexes[i].currentX);

    if (key=='w') SOF.flagseg=!SOF.flagseg; // segmentation on/off
    if (key=='m') SOF.flagmirror=!SOF.flagmirror; // mirror on/off
    else if (key=='i') SOF.flagimage=!SOF.flagimage; // show video on/off
    else if (key=='f') SOF.flagflow=!SOF.flagflow; // show opticalflow on/off
}



void polygon(int x, int y, int radius, int npoints)
{
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
        int sx = (int)(x + cos(a) * radius);
        int sy = (int)(y + sin(a) * radius);
        vertex(sx, sy);
    }
    endShape(CLOSE);
}

void changeHexagonColors(boolean hasGradient)
{
    //randomly setting starting hue
    int setHue = (int)random(0, 360);
    
    int j = 0;
    int i = 0;
    
    for (Hexagon hex : hexes)
    {
        //for rainbow gradient
        if (hasGradient == true)
        {
            setHue = (j + i) * 5;
        }
        
        //wrapping hue
        while (setHue > 360)
        {
            setHue -= 360;
        }
        
        //setting hue
        hex.mOrgHue = setHue;
        
        j++;
        if (j >= rows)
        {
            j = 0;
            i++;
        }
    }
    
}

void resetHexagons(boolean hasGradient)
{
    //deleting all hexagons
    hexes.clear();
    
    //creating new ones
        // --- creating hexagons
    int hexWidth = (int)(width / hexPerRow / 2.2);

    //randomly setting starting hue
    int setHue = (int)random(0, 360);

    for (int i = 0; i < hexPerRow; i++)
    {
        for (int j = 0; j < rows; j++)
        {
            //for rainbow gradient
            if (hasGradient == true)
            {
                setHue = (j + i) * 5;
            }
            
            //wrapping hue
            while (setHue > 360)
            {
                setHue -= 360;
            }
            
            Hexagon hex = null;

            //if odd, shift over
            if (j % 2 == 1)
            {
                hex = new Hexagon((int)(i * hexWidth * 2 * 1.3), (int)(j * hexWidth * 0.7), hexWidth, setHue);
            } else
            {
                hex = new Hexagon((int)(i * hexWidth * 2 * 1.3 - hexWidth * 1.3), (int)(j * hexWidth * 0.7), hexWidth, setHue);
            }
            //adding to array
            hexes.add(hex);
        }
    }
}
