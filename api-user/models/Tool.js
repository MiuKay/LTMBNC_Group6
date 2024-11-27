const mongoose = require('mongoose');

const toolSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  pic: { type: String }, 
});

module.exports = mongoose.model('Tool', toolSchema);
