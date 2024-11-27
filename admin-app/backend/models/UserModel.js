const mongoose = require("mongoose");

// Định nghĩa schema cho user
const userSchema = new mongoose.Schema({
    uid: { 
        type: String, 
        default: function () {
            return this._id.toString(); 
        }
    },
    fname: { type: String, required: true },
    lname: { type: String, required: true },
    email: { type: String, required: true },
    date_of_birth: { type: String, required: true },
    gender: { type: String, required: true },
    weight: { type: String, required: true },
    height: { type: String, required: true },
    pic: { type: String, default: "" },
    level: { type: String, required: true },
    expiresAt: { type: Number, default: 0 },
    otp: { type: String, default: "959724" },
    role: { type: String, default: "user" },
    activate: { type: Boolean, default: true },
    password: { type: String, default: "123456" },
});

// Hàm tính tuổi từ ngày sinh
userSchema.methods.getAge = function () {
    const date_of_birthParts = this.date_of_birth.split("/");
    const dob = new Date(
        parseInt(date_of_birthParts[2], 10), // Năm
        parseInt(date_of_birthParts[1], 10) - 1, // Tháng (0-based)
        parseInt(date_of_birthParts[0], 10) // Ngày
    );

    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();

    if (
        today.getMonth() < dob.getMonth() ||
        (today.getMonth() === dob.getMonth() && today.getDate() < dob.getDate())
    ) {
        age--;
    }

    return age;
};

// Hàm tĩnh để tạo đối tượng user từ JSON
userSchema.statics.fromJson = function (json) {
    return new this({
        fname: json.fname,
        lname: json.lname,
        email: json.email,
        date_of_birth: json.date_of_birth,
        gender: json.gender,
        weight: json.weight,
        height: json.height,
        pic: json.pic,
        level: json.level,
        expiresAt: json.expiresAt,
        otp: json.otp,
        role: json.role,
        activate: json.activate,
    });
};

// Tạo model
const UserModel = mongoose.model("User", userSchema);

module.exports = UserModel;
