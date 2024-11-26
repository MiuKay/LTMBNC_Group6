const mongoose = require('mongoose');

const stepExerciseSchema = new mongoose.Schema({
  detail: { type: String},
  name: { type: String, required: true }, 
  step: { type: Number, required: true },
  title: { type: String}, 
});

module.exports = mongoose.model('Step_exercies', stepExerciseSchema);