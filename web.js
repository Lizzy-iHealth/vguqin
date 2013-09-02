var fs = require('fs');

var content = fs.readFileSync("index.html").toString();
var express = require('express');
var app = express();
var ejs = require('ejs');

app.use(express.logger());
app.set('views',__dirname+'/views');
app.set('view engine','ejs');



var getFileName=function (request){
    var path =__dirname+request.path;
    return path;
}

var getFileContent=function(fn){
    return fs.readFileSync(fn).toString();
}

function prettyJSON(obj) {
    console.log(JSON.stringify(obj, null, 2));
}
function pREQ(obj){
    console.log("path is %s",obj.path);
}

var cn=JSON.parse(getFileContent("data/cn.json"));
app.get('/', function(request, response) {
	response.render("index",cn);
	// response.send(content);
//  pREQ(request);

});
app.get('/*.mp3',function(request,response){
  //  pREQ(request);
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
