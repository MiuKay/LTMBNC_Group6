const mongoose = require("mongoose");

// Định nghĩa schema cho UserModel
const userSchema = new mongoose.Schema({
    uid: { type: String, required: true },
    fname: { type: String, required: true },
    lname: { type: String, required: true },
    email: { type: String, required: true },
    dateOfBirth: { type: String, required: true },
    gender: { type: String, required: true },
    weight: { type: String, required: true },
    height: { type: String, required: true },
    pic: { type: String, required: true },
    level: { type: String, required: true },
});

// Phương thức tính tuổi từ ngày sinh
userSchema.methods.getAge = function () {
    const dateOfBirthParts = this.dateOfBirth.split("/");
    const dob = new Date(
        parseInt(dateOfBirthParts[2], 10),
        parseInt(dateOfBirthParts[1], 10) - 1,
        parseInt(dateOfBirthParts[0], 10)
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

// Phương thức tạo UserModel từ JSON
userSchema.statics.fromJson = function (json) {
    return new this({
        uid: json.uid,
        fname: json.fname,
        lname: json.lname,
        email: json.email,
        dateOfBirth: json.date_of_birth,
        gender: json.gender,
        weight: json.weight,
        height: json.height,
        pic: json.pic,
        level: json.level,
    });
};

// Định nghĩa model
const UserModel = mongoose.model("UserModel", userSchema);

module.exports = UserModel;
