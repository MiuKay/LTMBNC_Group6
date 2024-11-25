const mongoose = require('mongoose');

const cateWorkToolSchema = new mongoose.Schema({
  id_cate: { type: mongoose.Schema.Types.ObjectId, ref: 'CategoryWorkout', required: true },
  id_tool: { type: mongoose.Schema.Types.ObjectId, ref: 'Tool', required: true },
})
const CateWorkTool = mongoose.model('CateWorkTool', cateWorkToolSchema);
module.exports = CateWorkTool;