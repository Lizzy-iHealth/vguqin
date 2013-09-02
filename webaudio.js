window.onload = init;
var context;
var bufferLoader;
var sourceList=[];
var sourceNameList=[];
var bufferList=[];
var loaded=false;
var bound = false;
var ready = false;
var gainNodeList=[];

function bindJavascript() {
    var pjs = Processing.getInstanceById('qin_full');
    if(pjs!=null) {
      pjs.bindJavascript(this);
      bound = true;
    }
    if(!bound) setTimeout(bindJavascript, 250);
  }

bindJavascript();
function init() {
  // Fix up prefixing
  window.AudioContext = window.AudioContext || window.webkitAudioContext;
  context = new AudioContext();
  for (var i=0;i<7;i++){
      sourceNameList[i]=i+1+"-"+"0.mp3";
      sourceNameList[7+i]=i+1+"-"+"2.mp3"
    }
  
  bufferLoader = new BufferLoader(
    context,sourceNameList,finishedLoading);
  ready=true;  
  bufferLoader.load();
}

function finishedLoading(buffers) {

    for (var i=0; i<buffers.length;i++){
	bufferList[i]=buffers[i];
	}
    //sourceList[i]=context.createBufferSource();
    //sourceList[i].buffer = bufferList[i];  
    //sourceList[i].connect(context.destination);
    
    loaded=true;
//    play(1);
}
var getIndex=function(name,status){
    var index=name-1;
    if(status==3){index=index+7;}
    return index;
}

function setPlaybackRate(name,status,r){
    var index=getIndex(name,status);
   
    if(sourceList[index]){
	sourceList[index].playbackRate.value=r;
	}
}

function play(name,status,r){ 
    if(!ready){

  return;
    }
    if(!loaded){

  console.log("loading...");

         return;
    }
    var i=getIndex(name,status);
    sourceList[i]=context.createBufferSource();
    sourceList[i].buffer = bufferList[i];  
    sourceList[i].playbackRate.value=r;
    sourceList[i].connect(context.destination);
    sourceList[i].start(0);

}
