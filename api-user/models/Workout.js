const mongoose = require('mongoose');

const workoutSchema = new mongoose.Schema({
  id_cate: { type: String, required: true }, 
  name_exercise: { type: String, required: true }, 
  step: { type: Number, required: true },
});

module.exports = mongoose.model('Workout', workoutSchema);
