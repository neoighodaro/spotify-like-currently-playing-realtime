const express = require('express');
const bodyParser = require('body-parser');
const Pusher = require('pusher-js');
const fs = require('fs');
const path = require('path');
const app = express();

let current = {};
let tracks = JSON.parse(fs.readFileSync(path.resolve(__dirname, 'data.json')));

let pusher = new Pusher({
  appId: '474328',
  key: 'e869e6bdd555fab59a98',
  secret: '339363077939b0557d76',
  cluster: 'mt1',
  encrypted: true
});

app.get('/tracks', (req, res) => {
  res.json(tracks);
});

app.get('/current', (req, res) => {
  res.json(current);
});

app.post('/current', (req, res) => {
  for (let index = 0; index < tracks.data.length; index++) {
    if (tracks['data'][index]['id'] === parseInt(req.body.ID)) {
      current = tracks['data'][index];
      pusher.trigger('spot', 'current', current);
      break;
    }
  }

  res.json(current);
});

app.post('tick', (req, res) => {
  const { id, pos } = req.body;
  pusher.trigger('spot', 'tick', { id, pos });
});

app.listen(3000, () => console.log('Listening on port 3000!'));
