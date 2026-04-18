require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Routes
const authRoutes = require('./routes/auth');
const courseRoutes = require('./routes/courses');
app.use('/api/auth', authRoutes);
app.use('/api/courses', courseRoutes);

const PORT = process.env.PORT || 5000;
const { MongoMemoryServer } = require('mongodb-memory-server');

let MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/codementor';

async function connectToDatabase() {
  try {
    if (MONGO_URI.includes('127.0.0.1') || MONGO_URI.includes('localhost')) {
      console.log('Using in-memory MongoDB for local testing...');
      const mongoServer = await MongoMemoryServer.create();
      MONGO_URI = mongoServer.getUri();
    }
    
    await mongoose.connect(MONGO_URI);
    console.log('Connected to MongoDB');
    app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
  } catch (err) {
    console.error('MongoDB connection error:', err);
  }
}

connectToDatabase();
