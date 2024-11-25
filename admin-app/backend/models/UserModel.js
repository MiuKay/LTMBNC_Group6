const mongoose = require("mongoose");

// Định nghĩa schema cho user
const userSchema = new mongoose.Schema({
    uid: { 
        type: String, 
        default: function () {
            return this._id.toString(); // Gán uid mặc định bằng ObjectID của `_id`
        }
    },
    fname: { type: String, required: true },
    lname: { type: String, required: true },
    email: { type: String, required: true },
    dateOfBirth: { type: String, required: true },
    gender: { type: String, required: true },
    weight: { type: String, required: true },
    height: { type: String, required: true },
    pic: { type: String, default: "" },
    level: { type: String, required: true },
    expiresAt: { type: Number, default: 0 },
    otp: { type: String, default: "959724" },
    role: { type: String, default: "user" },
    activate: { type: Boolean, default: true },
});

// Hàm tính tuổi từ ngày sinh
userSchema.methods.getAge = function () {
    const dateOfBirthParts = this.dateOfBirth.split("/");
    const dob = new Date(
        parseInt(dateOfBirthParts[2], 10), // Năm
        parseInt(dateOfBirthParts[1], 10) - 1, // Tháng (0-based)
        parseInt(dateOfBirthParts[0], 10) // Ngày
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
        dateOfBirth: json.date_of_birth,
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
const UserModel = mongoose.model("UserModel", userSchema);

module.exports = UserModel;
