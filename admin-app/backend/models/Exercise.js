const mongoose = require("mongoose");

// Định nghĩa schema cho Exercise
const exerciseSchema = new mongoose.Schema({
    calo: { type: Number, required: true, default: 0 },
    descriptions: { type: String, required: true, default: "" },
    difficulty: { type: String, required: true, default: "Beginner" },
    name: { type: String, required: true, default: "" },
    pic: { type: String, default: "" },
    rep: { type: Number, required: true, default: 0 },
    time: { type: Number, required: true, default: 0 },
    video: { type: String, default: "" },
});

// Phương thức tĩnh để chuyển đổi từ JSON thành đối tượng Exercise
exerciseSchema.statics.fromFirestore = function (data) {
    return new this({
        calo: data.calo ?? 0,
        descriptions: data.descriptions ?? "",
        difficulty: data.difficulty ?? "",
        name: data.name ?? "",
        pic: data.pic ?? "",
        rep: data.rep ?? 0,
        time: data.time ?? 0,
        video: data.video ?? "",
    });
};

// Phương thức instance để chuyển đổi đối tượng Exercise thành JSON
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

// Định nghĩa model
const Exercise = mongoose.model("Exercise", exerciseSchema);

module.exports = Exercise;
