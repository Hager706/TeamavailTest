const express = require('express');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const redis = require('redis');

const app = express();
const PORT = 3000;

// Create Redis client
const redisClient = redis.createClient({
  host: 'redis',  // Docker service name
  port: 6379
});

redisClient.on('error', (err) => {
  console.log('Redis Client Error', err);
});

redisClient.on('connect', () => {
  console.log('Connected to Redis');
});

// Connect to Redis
redisClient.connect();

// Middleware
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/input', express.static(path.join(__dirname, 'input')));
app.use('/output', express.static(path.join(__dirname, 'output')));

// API to save history data
app.post('/save-history', async (req, res) => {
  const historyPath = path.join(__dirname, 'output', 'history.json');
  const json = JSON.stringify(req.body, null, 2);
  
  try {
    // Save to file (existing functionality)
    await fs.promises.writeFile(historyPath, json, 'utf8');
    console.log('History saved to file.');
    
    // Save to Redis (new functionality)
    const redisKey = `availability:${Date.now()}`;
    await redisClient.setEx(redisKey, 3600, json); // Expire in 1 hour
    console.log('History saved to Redis with key:', redisKey);
    
    // Also save a "latest" key
    await redisClient.set('availability:latest', json);
    console.log('Latest availability saved to Redis');
    
    res.status(200).send('Saved to both file and Redis');
  } catch (err) {
    console.error('Error saving history:', err);
    res.status(500).send('Failed to save history');
  }
});

// API to get latest data from Redis
app.get('/api/latest-availability', async (req, res) => {
  try {
    const data = await redisClient.get('availability:latest');
    if (data) {
      res.json(JSON.parse(data));
    } else {
      res.status(404).json({ message: 'No data found' });
    }
  } catch (err) {
    console.error('Error getting data from Redis:', err);
    res.status(500).json({ error: 'Failed to get data' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});