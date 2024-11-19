const mongoose = require('mongoose');

const stepExerciseSchema = new mongoose.Schema({
    name: { type: String, required: true },
    step: { type: Number, required: true },
    title: { type: String, required: true },
    detail: { type: String, required: true },
});

stepExerciseSchema.statics.fromJson = function (json) {
    return new this({
    name: json.name,
    step: json.step,
    title: json.title,
    detail: json.detail,
    });
};
  
stepExerciseSchema.methods.toJson = function () {
    return {
        name: this.name,
        step: this.step,
        title: this.title,
        detail: this.detail,
    };
};

const StepExercise = mongoose.model('StepExercise', stepExerciseSchema);

module.exports = StepExercise;