const mongoose = require('mongoose');

const toolSchema = new mongoose.Schema({
    _id: { type: String, required: true }, // Firestore document ID
    name: { type: String, required: true },
    pic: { type: String, required: true },
})

const Tool = mongoose.model('Tool', toolSchema);
module.exports = Tool;