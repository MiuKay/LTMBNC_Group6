const mongoose = require('mongoose');

const exerciseSchema = new mongoose.Schema({
    calo: { type: Number, required: true, default: 0 },
    descriptions: { type: String, required: true, default: "" },
    difficulty: { type: String, required: true, default: "" },
    name: { type: String, required: true, default: "" },
    pic: { type: String, required: true, default: "" },
    rep: { type: Number, required: true, default: 0 },
    time: { type: Number, required: true, default: 0 },
    video: { type: String, required: true, default: "" },
});


// Phương thức chuyển đổi từ JSON sang Exercise
exerciseSchema.statics.fromFirestore = function (data) {
  return new Exercise({
    calo: data.calo || 0,
    descriptions: data.descriptions || '',
    difficulty: data.difficulty || '',
    name: data.name || '',
    pic: data.pic || '',
    rep: data.rep || 0,
    time: data.time || 0,
    video: data.video || '',
  });
};

// Phương thức chuyển đổi từ Exercise sang JSON
exerciseSchema.methods.toFirestore = function () {
  return {
    calo: this.calo,
    descriptions: this.descriptions,
    difficulty: this.difficulty,
    name: this.name,
    pic: this.pic,
    rep: this.rep,
    time: this.time,
    video: this.video,
  };
};

const Exercise = mongoose.model('Exercise', exerciseSchema);
module.exports = Exercise;