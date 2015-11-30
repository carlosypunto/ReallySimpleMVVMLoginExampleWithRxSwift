

var express = require('express');
var app = express();

app.get('/login/:username/:password', function(req, res) {

  const username = req.params.username
  const password = req.params.password

  res.type('application/json');

  // simulate network delay
  setTimeout(function() {
    if (username == 'error') {
      res.statusCode = 520;
      res.json({
        "login_status": false,
        "error": 'This user alwais fail.'
      })
    }
    else {
      if (username == 'user' && password == 'password') {
        res.json({
          "login_status": true,
          "user": {
              "firstname": "John",
              "lastname": "Doe"
            }
        })
      }
      else {
        res.json({
          "login_status": false,
          "error": 'Unknown user'
        })
      }
    }
  }, 4000)

});

app.get('*', function(req, res) {
  res.type('text/plain');
  // simulate network delay
  setTimeout(function() {
    res.send('Nothing here ¯\\_(ツ)_/¯');
  }, 4000)
});

var port = process.env.PORT || 3000
app.listen(port);
console.log("Listen on: http://localhost:"+port+"/")