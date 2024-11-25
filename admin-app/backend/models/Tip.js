const mongoose = require("mongoose");

// Định nghĩa schema cho Tip
const tipSchema = new mongoose.Schema({
    detail: { type: String, required: true, default: "" },
    name: { type: String, required: true, default: "" },
    pic: { type: String, default: "" },
});

// Phương thức tĩnh để chuyển đổi từ JSON (Firestore document) sang Tip
tipSchema.statics.fromFirestore = function (data) {
    return new this({
        detail: data.detail ?? "",
        name: data.name ?? "",
        pic: data.pic ?? "",
    });
};

// Phương thức instance để chuyển đổi từ Tip sang JSON (Firestore document)
tipSchema.methods.toFirestore = function () {
    return {
        detail: this.detail,
        name: this.name,
        pic: this.pic,
    };
};

// Định nghĩa model
const Tip = mongoose.model("Tip", tipSchema);

module.exports = Tip;
