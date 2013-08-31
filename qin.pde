import ddf.minim.*;

int DEFAULT_XIAN_NUM =7;
Xian[] xian;
Hui[] hui;
int DEFAULT_HUI_NUM = 13;
float[] xianHight;
int FrameRate = 30;
int DEFAULT_PLAY_TIME = 3 ;// 2s play time
float DEFAULT_AMP=6;
float EPS = 5;
float xianHead;
float xianTail=0;
Minim minim;
PlayHistory history;
//MelodyManager melodyManager;
int mode; //1: nomal, 2:Melody

void setup(){
  size(1000,360);
  frameRate(FrameRate);
  minim = new Minim(this);
  
  history = new PlayHistory();
  // draw static Xian 
  xianHead=width;
  xianTail=0;
  float xianTop = height*0.2;
  float xianBottom = height*0.95;
  
  float xianOffset=(xianBottom-xianTop)/(DEFAULT_XIAN_NUM-1);
  EPS=xianOffset*0.3;
  xian = new Xian[DEFAULT_XIAN_NUM];
  float [] xianHeight = new float[DEFAULT_XIAN_NUM];
  for(int i = 0; i<DEFAULT_XIAN_NUM; ++i){
     
     float currentXianHeight = xianTop + xianOffset * i;
     xianHeight[i] = currentXianHeight;
     xian[i]= new Xian(i+1,xianHead,currentXianHeight,xianTail,currentXianHeight,ceil((9-i)/2));
  }
  ellipseMode(RADIUS);
  // initHui;
  
  float huiHeight = height*0.1;
  float cr = (xianTop-huiHeight)*0.2;
  float[] hr = new float[DEFAULT_HUI_NUM];
  float[] hxRate={ 0.125 , 0.166 , 0.2 , 0.25, 0.333 , 0.4 , 0.5, 0.6 , 0.666 , 0.75, 0.8, 0.833 ,0.875  } ;
  float HuiZoomRate = 0.9;
  float mr = cr * pow(HuiZoomRate,floor(DEFAULT_HUI_NUM/2));
  for(int i =0; i<= DEFAULT_HUI_NUM/2; i++){
    hr[i]=mr;
    hr[DEFAULT_HUI_NUM-1-i]=mr;
    mr=mr/HuiZoomRate;
  }
  float xianLen=xianHead-xianTail;
  hui = new Hui[DEFAULT_HUI_NUM];
  for(int i =0; i< DEFAULT_HUI_NUM; i++){
    hui[i]=new Hui(DEFAULT_HUI_NUM-i,xianTail+xianLen*hxRate[i],huiHeight,hr[i]);
  }
  
  //initMelody();
  //melodyManager = new MelodyManager("playlist.txt");
  mode=1;
}

boolean moveAlongX(int px, int py, int x, int y){
  
  if( abs(px-x)>abs(py-y)) return true;
  else return false;
}  
// Drag (click and hold) your mouse across the 
// image to change the value of the rectangle
void mouseDragged() {
     if(moveAlongX(pmouseX,pmouseY,mouseX,mouseY)){
              for(int i = 0; i<DEFAULT_XIAN_NUM;i++){
               if(xian[i].near(mouseX,mouseY)){
                 int status = 2;
                 if(xian[i].status!=20){ //not already played.
                   play(i,status,DEFAULT_AMP,mouseX,xianHead);
                 }
               }
         }
     }else{
       for(int i = 0; i<DEFAULT_XIAN_NUM;i++){
         if(xian[i].crossed(pmouseX,pmouseY,mouseX,mouseY)){
         int status = 1;
         play(i,status,DEFAULT_AMP,xianTail,mouseX);
       }
     }
     }
}
void mouseReleased(){
     for(int i = 0; i<DEFAULT_XIAN_NUM;i++){
     if(xian[i].near(mouseX,mouseY)&&xian[i].status==20){
        xian[i].status=0;
     }
   }
}

/*
void mouseMoved(){
  
   for(int i = 0; i<DEFAULT_XIAN_NUM;i++){
     if(xian[i].crossed(pmouseX,pmouseY,mouseX,mouseY)){
       int status = 1;
       
       play(i,status,DEFAULT_AMP,0,mouseX);
     }
   }

       
}
*/
void mouseClicked(){
  
   for(int i = 0; i<DEFAULT_XIAN_NUM;i++){
     if(xian[i].near(mouseX,mouseY)){
       int status = 3;
       play(i,status,DEFAULT_AMP*0.3,mouseX,xianHead);
     }
   }
       
}
void play (int i,int status,float a, float l, float r){ // xian index, vibrate status(0 still,1 san,2 an,3 fan), amplitude, lefthand position, right hand position, amplitude
    xian[i].play(status,a,l,r);
    Note n = new Note(xian[i].name,status,a,l,r,millis());

    history.addNote(n);
    
    /*
    if(mode != 2){
      int[] id = history.getXianHistory(5);
      int mIndex = melodyManager.findMelodyById(id);
      if(mIndex>=0){
        mode = 2;
        melodyManager.play(mIndex);
      }
    }else{
      melodyManager.play();
    }
    */

}




void draw(){
  
  background(0);
  for(int i =0; i< DEFAULT_HUI_NUM; i++){
    hui[i].draw();
  }
  
  for (int i = 0; i < DEFAULT_XIAN_NUM; ++i){
    xian[i].update();
  }
  /*
  if(mode==2) {melodyManager.update();}
  */
}

void stop(){
  for(int i =0;i<DEFAULT_XIAN_NUM;i++){
    xian[i].stop();
  }
/*  melodyManager.stop();*/
  minim.stop();
  super.stop();
}
class Hui{
  float name;
  float centerX;
  float centerY;
  float radias;
  color c;
 
  
  Hui(float n, float x, float y, float r){
   name = n;
   centerX = x;
   centerY = y;
   radias = r;
   c=#F0F0F0;
  }
  
  void draw(){
    fill(c);
    ellipse(centerX,centerY,radias,radias);
  }
}
class Melody{
  int[]id; // default 5 notes' xian name;
  int idLen; // default 5;
  String name;
  String soundFile;
  int status; // 0 : not started,  1:played,  2: paused, 3: stoped (?)
  AudioPlayer player;
  
  Melody(int[]id, String name, String fn){
    this.id = id;
    idLen = id.length;
    this.name = name;
    soundFile = fn;
  }
  
  void loadFile(){
    if(player==null){
    player = minim.loadFile(soundFile);
    }
  }
  
  boolean matched(int[] his){
    if (his.length!=idLen){
      return false;
    }
    for (int i = 0; i< id.length; i++){
      if (his[i]!=id[i]){
        return false;
      }
    }
    return true;
  }
  
  void play(){
    if (player==null){
      loadFile();
    }
    player.play();
  }
  
  void rewind(){
    if(player==null){
      loadFile();
    }
    player.rewind();
  }
  
  boolean isPlaying(){
    return player.isPlaying();
  }
  void pause(){
    player.pause();
  }
  boolean isOver(){
    println(player.position()+"=="+player.length());
    return (player.length()-player.position()<100);
  }
  void stop(){
    if(player!=null){
      player.close();
    }
  }
}
class MelodyManager{
  
  String playList; // a file name, in which each line is an 5 decimal id,a melody name,a file name: x x x x x,melody name,file name 
  String[] mp3Names;
  Melody[] melodies;
  int melodyNum;
  int currentPlayingIndex;
  
  MelodyManager(String playList){
    this.playList = playList;
    currentPlayingIndex=-1;
    String[] lines = loadStrings(playList);
    if (lines == null){
      mp3Names = null;
      melodies = null;
      melodyNum = 0;
      println("empty play list.");
    } else{
      melodyNum = lines.length;
      melodies = new Melody[melodyNum];
      for (int i = 0; i< melodyNum; i++){
        String[] info = split(lines[i],',');
        if(info.length!=3){
          println("play list format:x x x x x,Melody Name,mp3 file name");
          return;
        }
        int[] id = int(split(info[0],' ')); //id
        melodies[i] = new Melody(id,info[1],info[2]);
      }       
    }
  }
  
  int findMelodyById(int[] id){
    for(int i =0; i<melodyNum; i++){
      if(melodies[i].matched(id)){
        return i; // return first match. TODO: random select from multiple match
      }
    }
    return -1;  // not found
  }
  
  void play(int index){
    if(index!=currentPlayingIndex){
      melodies[index].rewind();
      currentPlayingIndex = index;
    }
    melodies[index].play();
    
  }
  void play(){
    melodies[currentPlayingIndex].play();
  }
  boolean isPlaying(){
    return melodies[currentPlayingIndex].isPlaying();
  }
  void pause(){
    melodies[currentPlayingIndex].pause();
  }
  
  void update(){
    
      if(history.timeSinceLastPlayed()>DEFAULT_PLAY_TIME*1000){
        //fade out
        pause();
      }
      if(!melodies[currentPlayingIndex].isPlaying()){
        currentPlayingIndex=-1;
        mode=1;
      }
  }
void stop(){
  for (Melody m:melodies){
    m.stop();
  }
}  
    
}
class Note{
  String name;
  int xianName;
  int status;
  float a;
  float l; //lefthand postion: mouseX when clicked or pressed.
  float r; //righthand postion: mouseX when crossed.
  int startTime; 
 
  
  Note(int xianName,int status, float a, float l, float r,int startTime){
    name = null;
    this.xianName = xianName;
    this.a = a;
    this.l = l;
    this.r = r;
    this.startTime = startTime;
    this.status = status;
  }
  String toString(){
    return "("+name+" "+xianName+" "+status+" "+l+"--"+r + " " + startTime+") ";
  }
}
class PlayHistory{
  Note[] notes;
  int  historyBufferSize;
  int  last;
  int  total;
  
  PlayHistory(){
    historyBufferSize = 10;
    notes = new Note[historyBufferSize];
    last=-1;
    total = 0;
  }
  PlayHistory(int size){
    historyBufferSize = size;
    notes = new Note[historyBufferSize];
    last=0;
    total = 0;
  }
  void addNote(Note n){
    total++;
    last=(last+1)%historyBufferSize;
    notes[last]=n;
  }
  
  void printHistory(){
    int head = 0;
    int len = last+1;
    if(total>last+1){
      head = last+1;
      len = historyBufferSize;
    }
    for(int i = 0; i< len; i++){
      println(notes[(head+i)%historyBufferSize]);
    }
  }
  
  int[] getXianHistory(int len){
    int[] id = new int[len];
    int n = len;
    if(n>total)n=total; 
    int start = (last-n+1+historyBufferSize)%historyBufferSize;
    int i = 0;
    for(; i<n&& i<historyBufferSize; i++){
      id[i] = notes[(start+i)%historyBufferSize].xianName;
    }
    
    while(i < len){id[i++]=0;} //padding
    return id;
  }
  
  int timeSinceLastPlayed(){
    return millis()-notes[last].startTime; // end time will be better.
  }
}
class Xian {
  int name;
  float headX,headY,tailX,tailY,a,l,r;
  float dia; // diameter of xian
  float angle; // control amplitude;
  float time; // vibrate time length in seconds;
  float hz;
  String soundfile;
  int status;//0:stable, 1:san yin, 2 an yin, 3 fan yin, 20 an yin continue...
  
  int tunesNum;
  AudioPlayer[] tunes; // san, an, fan
  // Constructor
  Xian(int name, float headX,float headY,float tailX,float tailY,int dia){
    this.name = name;
    this.headX = headX;
    this.headY = headY;
    this.tailX = tailX;
    this.tailY = tailY;
    a=0;
    l=tailX;
    r=headX;
    this.dia=dia;
    hz = 200;
    tunesNum = 7; //0: san, 1: a7, 2: f7, 3:an-left, 4: an-right, 5: f9, 6: f4,  
    time = DEFAULT_PLAY_TIME;
    tunes = new AudioPlayer[tunesNum]; 
    loadSoundFile();
  }
  void loadSoundFile(){
    for (int i =0;i<tunesNum;i++){
      String fn = str(name)+"-"+str(i)+".mp3";
     // println("load:"+fn);
      tunes[i] = minim.loadFile(fn);
    }
  }
  void playTunes(int h){
    int i=0;
    switch (h){
      case 0:
        i = 0;
        break;
      case 1:
        if(l<tailX+0.333*(headX-tailX)){
          i=3;
        }else if(l<tailX+0.666*(headX-tailX)){
          i=1;
        }else {
          i=4;
        }
        break;
      case 2:
        if(l<tailX+0.333*(headX-tailX)){
          i=5;
        }else if(l<tailX+0.666*(headX-tailX)){
          i=2;
        }else {
          i=6;
        }
        break;
    }
    //println("tune index is "+i+"left position is "+l);
    tunes[i].rewind();
    tunes[i].play();
  }
  void play(int status,float a, float l, float r){
    this.status = status;
    vibrate(a,l,r);

    if(mode==1){
    switch (status){
      case 0:  // silent
        break;
      case 1:  //san yin
        playTunes(0);
        break;
      case 2:  // an yin
        playTunes(1);
        //until mouse up
        break;
      case 3: // fan yin
        playTunes(2);
    }
    }
    if(status==2)this.status = 20;
  }
  void draw(){
    stroke(255);
    strokeWeight(dia);
    float totalAngle = time*hz*2*PI;
    float curA = a*(1-angle/totalAngle)*cos(angle);
    switch (status) {
      case 0:
        line(tailX,tailY,headX,headY);
        break;
      case 1: // vibrate around right hand position

      case 2: // vibrate from left hand postion to head, around right hand position
      case 20:
        line(tailX,tailY,l,tailY); //tail to left position
        line(l,tailY,r,headY+curA);   // left hand to right hand
        line(r,headY+curA,headX,headY); // right hand to head
        break;
      case 3: // vibrate around left hand position.
        line(tailX,tailY,l,tailY+curA);
        line(l,tailY+curA,headX,headY);
        break;
    }
  }
  boolean crossed(int px, int py, int x,int y){
      if(py==y) return false; // no y direction move;
      if(py==headY) return false; // already played.
      if((py-headY)*(headY-y)>=0) {
        //println("cross: "+ name+py+headY+y);
        return true;
      }
      else return false;
  }
  boolean near(int x, int y){
    if(abs(y-headY)<EPS) return true;
    else return false;
  }
  void update(){
    if(status>0){
      float tA=time*hz*2*PI;
      angle+=2*PI*hz/FrameRate;
      if (angle > tA){
        status=0;
        angle =0; 
      }
    }
    draw();
  }
  
  boolean isVibrate(){
    return boolean(status);
  }
  
  void vibrate (float a, float l, float r){ //Amplitude, lefthand position, righthand position
    this.a=a;
    this.l=l;
    this.r=r;
    angle = 0;
  }
  
  void stop(){
    for (int i = 0; i<tunes.length; i++) {
      tunes[i].close();
    }
  }
}



