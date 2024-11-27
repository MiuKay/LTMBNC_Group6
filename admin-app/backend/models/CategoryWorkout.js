const mongoose = require("mongoose");
const WorkoutModel = require("./WorkoutModel"); // Import WorkoutModel

// Định nghĩa schema cho CategoryWorkout
const categoryWorkoutSchema = new mongoose.Schema({
    id: { type: String, required: true, default: function() { return this._id.toString(); } }, // Thêm trường id
    level: { type: [String], required: true, default: [] }, // Mảng các cấp độ
    name: { type: String, required: true, default: "" }, // Tên
    pic: { type: String, default: "" }, 
});

// Phương thức tĩnh để chuyển đổi từ JSON (Firestore document) sang CategoryWorkout
categoryWorkoutSchema.statics.fromFirestore = function (data) {
    return new this({
        id: data.id ?? "",
        level: data.level ?? [],
        name: data.name ?? "",
        pic: data.pic ?? "",
    });
};

// Phương thức instance để chuyển đổi từ CategoryWorkout sang JSON (Firestore document)
categoryWorkoutSchema.methods.toFirestore = function () {
    return {
        id: this.id,
        level: this.level,
        name: this.name,
        pic: this.pic,
    };
};

// Định nghĩa model
const CategoryWorkout = mongoose.model("CategoryWorkout", categoryWorkoutSchema);

module.exports = CategoryWorkout; 