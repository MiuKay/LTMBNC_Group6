const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  activate: { type: Boolean, default: false },
  date_of_birth: { type: String }, 
  email: { type: String, required: true, unique: true },
  expiresAt: { type: Number},
  fname: { type: String},
  lname: { type: String},
  gender: { type: String, enum: ['Male', 'Female']},
  height: { type: String},
  level: { type: String},
  otp: { type: String },
  password: { type: String, required: true },
  pic: { type: String },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  uid: { type: String, unique: true },
  weight: { type: String },
});

module.exports = mongoose.model('User', userSchema);
