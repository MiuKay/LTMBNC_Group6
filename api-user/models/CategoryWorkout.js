const mongoose = require('mongoose');

const categoryWorkoutSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  level: { type: [String], enum: ['Lose a Fat', 'Lean & Tone', 'Improve Shape'], required: true }, 
  name: { type: String, required: true },
  pic: { type: String, required: true },
});

module.exports = mongoose.model('CategoryWorkout', categoryWorkoutSchema);
