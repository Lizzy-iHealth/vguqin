var fs = require('fs');

var content = fs.readFileSync("index.html").toString();
var express = require('express');
var app = express();
app.use(express.logger());

var getFileName=function (request){
    var path =__dirname+request.path;
    return path;
}

function prettyJSON(obj) {
    console.log(JSON.stringify(obj, null, 2));
}
function pREQ(obj){
    console.log("path is %s",obj.path);
}

app.get('/', function(request, response) {
  response.send(content);
  pREQ(request);

});
app.get('/*.mp3',function(request,response){
    pREQ(request);
    var f=getFileName(request);
    response.sendfile(f);
});

app.get('/*.js',function(request,response){
    response.sendfile(getFileName(request));
 
});
app.get('/*.pde',function(request,response){
    response.sendfile(getFileName(request));
});


var port = process.env.PORT || 8080;
app.listen(port, function() {
  console.log("Listening on " + port);
});
