const mongoose = require("mongoose");

// Định nghĩa schema cho WorkoutSchedule
const workoutScheduleSchema = new mongoose.Schema({
    id: { type: String, required: true },
    uid: { type: String, required: true },
    name: { type: String, required: true },
    day: { type: String, required: true },
    hour: { type: String, required: true },
    difficulty: { type: String, required: true },
    notify: { type: Boolean, required: true },
    repeatInterval: { type: String, required: true },
});

// Phương thức tĩnh để chuyển đổi từ JSON sang WorkoutSchedule
workoutScheduleSchema.statics.fromFirestore = function (data) {
    return new this({
        id: data.id,
        uid: data.uid,
        name: data.name,
        day: data.day,
        hour: data.hour,
        difficulty: data.difficulty,
        notify: data.notify,
        repeatInterval: data.repeat_interval,
    });
};

// Phương thức instance để chuyển đổi từ WorkoutSchedule sang JSON
workoutScheduleSchema.methods.toMap = function () {
    return {
        id: this.id,
        uid: this.uid,
        name: this.name,
        day: this.day,
        hour: this.hour,
        difficulty: this.difficulty,
        notify: this.notify,
        repeat_interval: this.repeatInterval,
    };
};

// Định nghĩa model
const WorkoutSchedule = mongoose.model("WorkoutSchedule", workoutScheduleSchema);

module.exports = WorkoutSchedule;
