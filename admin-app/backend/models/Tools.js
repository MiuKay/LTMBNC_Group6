const mongoose = require("mongoose");

// Định nghĩa schema cho Tools
const toolsSchema = new mongoose.Schema({
    id: { type: String, required: true, default: function() { return this._id.toString(); } }, // Thêm trường id
    name: { type: String, required: true, default: "" }, // Tên công cụ
    pic: { type: String, default: "" }, // Hình ảnh (không yêu cầu)
});

// Phương thức tĩnh để chuyển đổi từ JSON (Firestore document) sang Tools
toolsSchema.statics.fromFirestore = function (data) {
    return new this({
        name: data.name ?? "",
        pic: data.pic ?? "",
    });
};

// Phương thức instance để chuyển đổi từ Tools sang JSON (Firestore document)
toolsSchema.methods.toFirestore = function () {
    return {
        name: this.name,
        pic: this.pic,
    };
};

// Định nghĩa model
const Tools = mongoose.model("Tools", toolsSchema);

module.exports = Tools; 