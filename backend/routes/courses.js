const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const auth = require('../middleware/auth');

// Use this mock data if DB is empty to demonstrate UI features easily
const MOCK_COURSES = [
  { title: "Python basics", language: "Python", difficulty: "Beginner", is_published: true },
  { title: "Java fundamentals", language: "Java", difficulty: "Intermediate", is_published: true },
  { title: "HTML & CSS", language: "HTML & CSS", difficulty: "Beginner", is_published: true }
];

// Seed db if needed (useful for Milestone presentation if DB is empty)
router.post('/seed', async (req, res) => {
  try {
    const existing = await Course.countDocuments();
    if (existing === 0) {
      await Course.insertMany(MOCK_COURSES);
      return res.json({ message: "Courses seeded successfully" });
    }
    res.json({ message: "Courses already exist" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all courses (Student Dashboard)
router.get('/', auth, async (req, res) => {
  try {
    const courses = await Course.find();
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get Mentor's specific courses
router.get('/my-courses', auth, async (req, res) => {
  try {
    const courses = await Course.find({ mentor_id: req.user.id });
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new course (Mentor Only feature context)
router.post('/', auth, async (req, res) => {
  try {
    const { title, language, difficulty, is_published } = req.body;
    const newCourse = new Course({ 
      mentor_id: req.user.id, 
      title, 
      language, 
      difficulty, 
      is_published 
    });
    await newCourse.save();
    res.json(newCourse);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
