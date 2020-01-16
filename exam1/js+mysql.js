//載入MySQL模組
var mysql = require('mysql');
//建立連線
var connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    database: 'my_db'
});

//開始連接
connection.connect();
var  sql = 'select * from user;'//'SELECT * FROM user';
var arr;
connection.query(sql,function (err, rows) {
    if(err){
      console.log('[SELECT ERROR] - ',err.message);
      return;
    }
    arr=rows;
});

var express = require('express');
var app = express();
app.get('/', function(req, res) {
    res.setHeader("Content-Type","text/html;charset=UTF-8");
    res.write("<head>"
        +"<style>"
        +"table, th, td {"
         + "border: 1px solid black;"
         + "border-collapse: collapse;"
        +"}"
        +"th, td {"
         + "padding: 5px;"
         + "text-align: left;"
        +"}</style>"
        +"</head>")
    res.write("<body>")
    res.write("<table style='width:80%'>")
    res.write("<caption style='text-align:center;'>Data table</caption>");
    res.write("<tr>");
    for (var prop in arr[0]) {
        res.write("<th>"+prop+"</th>");
    }
    res.write("</tr>");
    for (var i=0;i<arr.length;i++){
        res.write("<tr>");
        for (const [key, value] of Object.entries(arr[i])) {
            res.write("<td>"+value+"</td>"); 
          }
        res.write("</tr>");
    }
    res.write("</table>");
    res.write("</body>")
    res.end();
    
});
connection.end();
app.listen(3000);