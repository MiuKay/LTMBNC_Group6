const mongoose = require("mongoose");

// Định nghĩa schema cho StepExercise
const stepExerciseSchema = new mongoose.Schema({
    name: { type: String, required: true, default: ""},
    step: { type: Number, required: true },
    title: { type: String, required: true, default: ""},
    detail: { type: String, required: true , default: ""},
});

// Phương thức tĩnh để chuyển đổi từ JSON sang StepExercise
stepExerciseSchema.statics.fromJson = function (json) {
    return new this({
        name: json.name,
        step: json.step,
        title: json.title,
        detail: json.detail,
    });
};

// Phương thức instance để chuyển đổi từ StepExercise sang JSON
stepExerciseSchema.methods.toJson = function () {
    return {
        name: this.name,
        step: this.step,
        title: this.title,
        detail: this.detail,
    };
};

// Định nghĩa model
const StepExercise = mongoose.model("StepExercise", stepExerciseSchema);

module.exports = StepExercise;
