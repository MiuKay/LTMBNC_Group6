const mongoose = require("mongoose");

// Định nghĩa schema cho Workout
const workoutSchema = new mongoose.Schema({
    id_cate: { type: String, required: true }, // ID của CategoryWorkout
    name_exercise: { type: String, required: true }, // Tên bài tập
    step: { type: Number, required: true }, // Bước
});

// Phương thức tĩnh để tạo đối tượng Workout từ JSON
workoutSchema.statics.fromJson = function (json) {
    return new this({
        id_cate: json.id_cate,
        name_exercise: json.name_exercise,
        step: json.step,
    });
};

// Tạo model
const WorkoutModel = mongoose.model("Workout", workoutSchema);

module.exports = WorkoutModel; 