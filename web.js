var fs = require('fs');

var content = fs.readFileSync("index.html").toString();
var express = require('express');
var app = express();
var ejs = require('ejs');
var i18n = require('i18n');

app.use(express.logger());
app.use(i18n.init);
app.set('views',__dirname+'/views');
app.set('view engine','ejs');

i18n.configure({
    locales:['en', 'cn'],
    directory: __dirname + '/locales'

});

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
var en=JSON.parse(getFileContent("data/en.json"));
app.get('/', function(request, response) {
	response.render("index",en);
	// response.send(content);
//  pREQ(request);

});

app.get('/cn', function(request, response) {
    response.setLocale("cn");
    response.render("index",cn);
	// response.send(content);
//  pREQ(request);

});
app.get('/en', function(request, response) {
    response.setLocale("en");
	response.render("index",en);
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
