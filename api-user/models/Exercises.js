const mongoose = require('mongoose');

const exerciseSchema = new mongoose.Schema({
  calo: { type: Number, required: true },
  descriptions: { type: String, required: true },
  difficulty: { type: String, enum: ['Beginner', 'Normal', 'Professional'], required: true },
  name: { type: String, required: true },
  pic: { type: String, required: true },
  rep: { type: Number, default: 0 }, 
  time: { type: Number, default: 0 },
  video: { type: String }, 
});

module.exports = mongoose.model('Exercise', exerciseSchema);
