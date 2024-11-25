const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema({
  id_cate: { type: mongoose.Schema.Types.ObjectId, ref: 'CategoryWorkout', required: true}, // Reference to CategoryWorkout id
  exercise: { type: mongoose.Schema.Types.ObjectId, ref: 'Exercise', required: true }, // Name of the exercise
  step: { type: Number, required: true },
});

const Workout = mongoose.model('Workout', workoutSchema);
module.exports = Workout;