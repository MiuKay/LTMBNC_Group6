const mongoose = require('mongoose');

const tipSchema = new mongoose.Schema({
  detail: { type: String, required: true }, 
  name: { type: String, required: true },
  pic: { type: String }, 
});

module.exports = mongoose.model('Tip', tipSchema);
