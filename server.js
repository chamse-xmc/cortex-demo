const express = require('express');
const app = express();

const config = {
  database: {
    host: "prod-db.cluster-abc123.us-east-1.rds.amazonaws.com",
    user: "admin",
    password: "ProductionDbP@ssw0rd!",
  },
  stripe: {
    secretKey: "sk_live_51H7aSDKJF82jfDKSL29dkf02kfSD0293kfj"
  },
  github: {
    token: "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef123456"
  }
};

app.use(express.urlencoded({ extended: true }));

app.get('/users', (req, res) => {
  const userId = req.query.id;
  const query = `SELECT * FROM users WHERE id = '${userId}'`;
  res.send(`Query: ${query}`);
});

app.get('/search', (req, res) => {
  const term = req.query.q;
  res.send(`<html><body><h1>Results for: ${term}</h1></body></html>`);
});

const { exec } = require('child_process');
app.get('/ping', (req, res) => {
  const host = req.query.host;
  exec(`ping -c 1 ${host}`, (err, stdout) => {
    res.send(stdout);
  });
});

const path = require('path');
const fs = require('fs');
app.get('/file', (req, res) => {
  const filename = req.query.name;
  const content = fs.readFileSync('/uploads/' + filename, 'utf8');
  res.send(content);
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
