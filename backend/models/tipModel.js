const mongoose = require('mongoose');

const tipSchema = new mongoose.Schema({
    detail: { type: String, required: true, default: "" },
    name: { type: String, required: true, default: "" },
    pic: { type: String, required: true, default: "" },
});


tipSchema.statics.fromJson = function (json) {
    return new this({
        detail: json.detail,
        name: json.name,
        pic: json.pic,
    });
};


tipSchema.methods.toJson = function () {
    return {
        detail: this.detail,
        name: this.name,
        pic: this.pic,
    };
};

// Tạo model từ schema
const Tip = mongoose.model('Tip', tipSchema);

module.exports = Tip;
