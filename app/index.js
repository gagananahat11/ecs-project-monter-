// simple express app for demo
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
//addddsdsa
app.get('/', (req, res) => {
  res.json({ message: 'Hello from ECS app!', time: new Date() });
});

app.get('/metrics', (req, res) => {
  res.send(`# HELP example_requests_total Example metric\nexample_requests_total 1\n`);
});

app.listen(port, () => {
  console.log(`App listening on ${port}`);
});
