const mongoose = require('mongoose');

const categoryWorkoutSchema = new mongoose.Schema({
  _id: { type: String, required: true }, // Firestore document ID
  name: { type: String, required: true },
  pic: { type: String, required: true },
  level: { type: [String], required: true }, // Array of levels
});

const CategoryWorkout = mongoose.model('CategoryWorkout', categoryWorkoutSchema);
module.exports = CategoryWorkout;