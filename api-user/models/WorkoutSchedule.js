const mongoose = require('mongoose');

const workoutScheduleSchema = new mongoose.Schema({
  day: { type: String }, 
  difficulty: { type: String },
  hour: { type: String }, 
  id: { type: String, required: true, unique: true },
  id_cate: { type: String }, 
  id_notify: { type: String }, 
  name: { type: String },
  notify: { type: Boolean, default: true }, 
  pic: { type: String}, 
  repeat_interval: { type: String, default: "no" }, 
  uid: { type: String, required: true },
});

module.exports = mongoose.model('WorkoutSchedule', workoutScheduleSchema);
