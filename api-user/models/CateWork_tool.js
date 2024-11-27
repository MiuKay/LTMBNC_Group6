const mongoose = require('mongoose');

const cateWorkToolSchema = new mongoose.Schema({
  id_cate: { type: String, required: true }, 
  id_tool: { type: String, required: true }, 
});

module.exports = mongoose.model('CateWorkTool', cateWorkToolSchema);
