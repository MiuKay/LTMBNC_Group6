const mongoose = require('mongoose');

// Định nghĩa schema cho WorkoutSchedule
const workoutScheduleSchema = new mongoose.Schema({
    id: {type: String, required: true,},
    uid: {type: String, required: true,},
    name: {type: String, required: true,},
    day: {type: String, required: true,},
    hour: {type: String, required: true,},
    difficulty: {type: String, required: true,},
    notify: {type: Boolean, required: true,},
    repeatInterval: {type: String, required: true,},
    id_notify: {type: String, required: true,},
});

// Phương thức chuyển đổi từ JSON sang WorkoutSchedule
workoutScheduleSchema.statics.fromJson = function (json) {
    return new this({
        id: json.id,
        uid: json.uid,
        name: json.name,
        day: json.day,
        hour: json.hour,
        difficulty: json.difficulty,
        notify: json.notify,
        repeatInterval: json.repeat_interval,
        id_notify: json.id_notify,
    });
};

// Phương thức chuyển đổi từ WorkoutSchedule sang JSON
workoutScheduleSchema.methods.toJson = function () {
    return {
        id: this.id,
        uid: this.uid,
        name: this.name,
        day: this.day,
        hour: this.hour,
        difficulty: this.difficulty,
        notify: this.notify,
        repeat_interval: this.repeatInterval,
        id_notify: this.id_notify,
    };
};

// Tạo model từ schema
const WorkoutSchedule = mongoose.model('WorkoutSchedule', workoutScheduleSchema);

module.exports = WorkoutSchedule;
