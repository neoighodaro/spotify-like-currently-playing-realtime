const express = require('express');
const bodyParser = require('body-parser');
const Pusher = require('pusher');
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
  useTLS: true
});

app.use(bodyParser.urlencoded({ extended: true }));

app.get('/tracks', (req, res) => res.json(tracks));
app.get('/current', (req, res) => res.json(current));

app.post('/tick', (req, res) => {
  const { id, position, device } = req.body;

  for (let index = 0; index < tracks.length; index++) {
    if (tracks[index]['id'] === parseInt(id)) {
      current = tracks[index];
      pusher.trigger('spotmusic', 'tick', { id, position, device });
      return res.json({ status: true });
    }
  }

  res.json({ status: false });
});

app.listen(3000, () => console.log('Listening on port 3000!'));
