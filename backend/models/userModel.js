const mongoose = require('mongoose')

const userSchema = new mongoose.Schema({
    uid: { type: String,},
    fname: { type: String, required: true },
    lname: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    dateOfBirth: { type: String,  },
    gender: { type: String,  },
    weight: { type: String, },
    height: { type: String, },
    pic: [{type:String, required:true}],
    level: { type: String, },
    activate: { type: Boolean, default: false }, 
    storedOtp: { type: String,}, 
    expiresAt: { type: Number,},
    password: { type: String, required: true },
    role: { type: String, default: 'user' },
})



userSchema.methods.getAge = function () {
    const dob = new Date(this.dateOfBirth.split('/').reverse().join('-')); // Chuyển đổi "dd/MM/yyyy" thành "yyyy-MM-dd"
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
        activate: json.activate,
        storedOtp: json.storedOtp,
        expiresAt: json.expiresAt,
        password: json.password,
        role: json.role,
    });
};
const UserModel = mongoose.model('User', userSchema);
module.exports = UserModel;