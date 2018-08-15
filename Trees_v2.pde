Tree[] tree = new Tree[1]; // change the array size for new trees
float frame = 0;
String fldr;
boolean captureVideo = false; // turn this on if you want to capture pngs on every frame
boolean keyboardScreenshots = false; // turn this on if you want key presses to save imgs 

void setup(){
  size(300,800);
  newTrees();
  stroke(0);
  fldr = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
}

void draw(){
  background(200);
  frame += 0.05;
  for (int i = 0; i < tree.length; i++){
    tree[i].trunk.display(tree[i].x, height, tree[i].baseSize);
  }
  if (captureVideo){
    if (frame < 5){
      saveFrame("./"+fldr+"/####.png");   
    } else {
      frame = 0;
      newTrees();
    }
    if (frameCount >= 1000){
      exit();  
    }
  }
}

void keyReleased(){
  if (keyboardScreenshots){
    save("./images/" + year()+"-"+month() +"-"+day()+"-"+hour()+"-"+minute()+"-"+second()+frame);
  }
}

void mouseReleased(){
  newTrees(); // randomizes trees
}

void newTrees(){
  for (int i =0; i < tree.length; i++){
    tree[i] = new Tree();  
  }  
}

float applyGravity(float aang, float ll, float in){
  // this shit doesn't work :/ 
  float ang = aang;
  float applyAmt = (float) Math.sin((ang/200)*PI);
  while (ang > 2*PI){
    ang-= 2*PI;  
  }
  ang += (((PI) - ang))*(in * applyAmt);
  return ang;  
}

float[] norml(float x, float y, float len){ // take in x and y val, plus how long you want the final vec2
  float[] retval = new float[2];
  float c = (float) Math.sqrt(Math.pow(x,2) + Math.pow(y,2));
  retval[0] = (x/c) * len;
  retval[1] = (y/c) * len;
  return retval; // passes back an array with an x and y value
}

//--------------------------------------------------
//--------------------------------------------------CLASSES
//--------------------------------------------------

class Tree{ // this is where the meat of the generation is happening!
  //int fork = Math.round(random(8));
  float x = width/2+random(-20,20); // this is where the tree is positioned on screen
  int fork = (int) random(2,5); // how many branches at each fork
  int iterations = (int) random(4,10); // how many times it forks
  float spread = random(1,7);  // how wide the fork spreads
  float splay = random(0.2,1.1); // variation on the length of branches at a fork - low number makes outer branches shorter
  float lenMulti = random(0.5,0.95); // scale of child branches compared to parents
  float widMulti = random(0.2,0.8); // width of ^
  float baseSize = random(1,3)*float(iterations); // how wide the tree trunk starts
  float gravity = 0; // not really working - value of 1 should pull all branches straight down 
  float breezeStrength = random(1)+3; // how much the branches sway. 0 is still
  float leafSize = random(5,15); 
  Branch trunk = new Branch(this, PI, 0, height/random(2,4), baseSize, fork, iterations-1); // uses above settings to make the tree
  
}

class Branch{
   boolean terminus = false;
   int branchCount;
   float len;
   float wid;
   float localAngle = 0;
   float globalAngle = 0;
   float waveOffset = random(-1,1); // this just makes it so that all the branches aren't waving in perfect unison
   Branch[] branches = new Branch[0]; // array of child branches
   Tree tree; // parent tree - uses this to get a bunch of tree specific settings
   
   Branch(Tree tt, float gA, float lA, float ll, float ww, int bC, int iT){
     tree = tt; globalAngle = gA; localAngle = lA; len = ll; wid = ww; branchCount = bC;
     //gA = applyGravity(gA,len,tree.gravity); // applies gravity (doesnt' work)
     // checks if this is the final iteration, in which case it makes a leaf
     // if it's not, it instead makes more branches
     if (iT == 0){
       terminus = true;
     } else {
       terminus = false;
       branches = new Branch[branchCount];
       float minAng = -((tree.spread*(branchCount-1))/2);
       for (int i = 0; i < branches.length; i++){
         float thisBranchAng = ((tree.spread * i) + minAng + random(-0.5,0.5))*(tree.splay/iT);
         float thisBranchLenDiv = (float) (Math.abs(i-(float(tree.fork-1)/2))+1);
         branches[i] = new Branch(tree, gA+thisBranchAng, thisBranchAng, (len*tree.lenMulti)/thisBranchLenDiv, ww*tree.widMulti, bC, iT-1);  
       }
     }
     len *= random(.2,1.5); // randomizes its own length, but only after making children
   }
   
   void display(float sX, float sY, float ww){
     // determines angle of branch
     float breeze = (sin(frame+waveOffset)/len)*tree.breezeStrength;
     float eX = (float)(sX + (Math.sin((globalAngle+breeze))*len));
     float eY = (float)(sY + (Math.cos((globalAngle+breeze))*len));
     
     //line(sX,sY,eX,eY); // use this for line branches

     // use below for quad branches
     float[] widMath = norml(sX-eX,sY-eY,ww);
     float temp=widMath[0];
     widMath[0]=-widMath[1];
     widMath[1]=temp;
     float sX1 = sX+widMath[0];
     float sY1 = sY+widMath[1];
     float sX2 = sX-widMath[0];
     float sY2 = sY-widMath[1];
     widMath = norml(sX-eX,sY-eY,wid);
     temp=widMath[0];
     widMath[0]=-widMath[1];
     widMath[1]=temp;
     float eX1 = eX+widMath[0];
     float eY1 = eY+widMath[1];
     float eX2 = eX-widMath[0];
     float eY2 = eY-widMath[1];
     noStroke();
     fill(100);
     quad(sX1,sY1,sX2,sY2,eX2,eY2,eX1,eY1);
     for (int i = 0; i < branches.length; i++){
       branches[i].display(eX,eY,wid);
     }
     
     if (branches.length == 0){ // if this branch has no children, make a leaf
       fill(50);
       ellipse(eX,eY,tree.leafSize,tree.leafSize);
     }
   }
}

class Slider{
  float xC, yC, wd, h, min, max, pos;
  String txt;
  Slider(float xx, float yy, float wwd, float hh, String ttxt){
    xC = xx; yC = yy; wd = wwd; h = hh; txt = ttxt;
    min = xC- ((wd/2)-(h/2));
    max = xC+ ((wd/2)-(h/2));
    pos = min;
  }
  Slider(){
    xC = 0; yC = 0; wd = 50; h = 15; txt = "SLIDER";
    min = xC- ((wd/2)-(h/2));
    max = xC+ ((wd/2)-(h/2));
    pos = min;
  }
  void display(){
    
  }
  void interaction(){
    boolean active = false;
    if (mouseX >= pos-(h/2) && mouseX <= pos+(h/2) && mouseY >= yC -(h/2) && mouseY <= yC+(h/2)){
      active = true;
    } 
    pos = mouseX;
  }
}

class Button{
  boolean prsd = false;
  float xC, yC, wd, h;
  String txt;
  Button(float xx, float yy, float wwd, float hh, String ttxt){
    xC = xx; yC = yy; wd = wwd; h = hh; txt = ttxt;
  }
  Button(){
    xC = 0; yC = 0; wd = 100; h = 15; txt = "BUTTON";
  }
  void interaction(){
    if (mouseX>=xC-(wd/2)&&mouseX<=xC+(wd/2)&&mouseY>=yC-(h/2)&&mouseY<=yC+(h/2)){
      boolean prsd = true;
    }
  }
  void display(){
    if (prsd){
     
      stroke(255);
      fill(0);
    }else{
      stroke(0);
      fill(255);
    }
    textAlign(CENTER,CENTER);
    rect(xC-(wd/2),yC-(h/2),wd,h);
    fill(0);
    text(txt,xC,yC);
  }
}