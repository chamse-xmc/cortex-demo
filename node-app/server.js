// Intentionally vulnerable Node.js app for Cortex Cloud demo
// DO NOT deploy this application

const express = require('express');
const app = express();

// VULN: Hardcoded credentials
const AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE";
const AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY";
const DB_PASSWORD = "ProductionDbP@ssw0rd!";
const JWT_SECRET = "my-super-secret-jwt-key-12345";
const API_KEY = "sk-proj-abc123def456ghi789jkl012mno345pqr678stu901vwx";

// VULN: Sensitive config object
const config = {
  database: {
    host: "prod-db.cluster-abc123.us-east-1.rds.amazonaws.com",
    user: "admin",
    password: DB_PASSWORD,
    name: "production"
  },
  stripe: {
    secretKey: "sk_live_51H7aSDKJF82jfDKSL29dkf02kfSD0293kfj"
  },
  sendgrid: {
    apiKey: "SG.abc123def456.ghi789jkl012mno345pqr678stu901vwx234yz"
  },
  github: {
    token: "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef123456"
  }
};

app.use(express.urlencoded({ extended: true }));

// VULN: SQL injection via string concatenation
app.get('/users', (req, res) => {
  const userId = req.query.id;
  const query = `SELECT * FROM users WHERE id = '${userId}'`;
  res.send(`Query: ${query}`);
});

// VULN: XSS - reflecting user input without sanitization
app.get('/search', (req, res) => {
  const term = req.query.q;
  res.send(`<html><body><h1>Results for: ${term}</h1></body></html>`);
});

// VULN: Command injection
const { exec } = require('child_process');
app.get('/ping', (req, res) => {
  const host = req.query.host;
  exec(`ping -c 1 ${host}`, (err, stdout) => {
    res.send(stdout);
  });
});

// VULN: Path traversal
const path = require('path');
const fs = require('fs');
app.get('/file', (req, res) => {
  const filename = req.query.name;
  const content = fs.readFileSync('/uploads/' + filename, 'utf8');
  res.send(content);
});

app.listen(3000, () => {
  console.log('Demo app running on port 3000');
});
