const mongoose = require('mongoose');

const workoutHistorySchema = new mongoose.Schema({
  _id: { type: String, required: true }, // Firestore document ID
  uid: { type: String, required: true },
  id_cate: { type: mongoose.Schema.Types.ObjectId, ref: 'CategoryWorkout', required: true },
  exercisesArr: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Exercise', required: true }],
  index: { type: Number, required: true },
  duration: { type: Number, required: true },
  caloriesBurned: { type: Number, required: true },
  completedAt: { type: Date },
  difficulty: { type: String, required: true },
});

const WorkoutHistory = mongoose.model('WorkoutHistory', workoutHistorySchema);
module.exports = WorkoutHistory;