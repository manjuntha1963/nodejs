const express = require('express');
const app = express();
const PORT = 3000;

// Simple route with background color
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Node.js App</title>
        <style>
          body {
            background-color: lightblue;
            color: black;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: Arial, sans-serif;
            font-size: 2rem;
          }
        </style>
      </head>
      <body>
        🚀 WELCOME TO NODEJS APPLICATION 🚀
      </body>
    </html>
  `);
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
