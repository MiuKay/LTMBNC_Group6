const mongoose = require('mongoose');
const Exercise = require('../models/Exercises');

const workoutHistorySchema = new mongoose.Schema({
  caloriesBurned: { type: Number, default : 0 },
  completedAt: { type: Date},
  difficulty: { type: String },
  duration: { type: Number, default : 0 }, 
  exercisesArr: { type: [Exercise]}, 
  id: { type: String, required: true, unique: true },
  id_cate: { type: String }, 
  uid: { type: String, required: true }, 
});

module.exports = mongoose.model('WorkoutHistory', workoutHistorySchema);
