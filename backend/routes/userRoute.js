const  UserModel  = require('../models/userModel.js');
const cloudinary = require("../config/cloudinary");
const upload = require("../middlewares/multer");
const { ImageUpload } = require('../models/imageUpload.js');


const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require("fs");
const nodemailer = require('nodemailer');
const crypto = require('crypto');


const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
	port: 587,
    auth: {
        user: 'aaaaa@gmail.com',  /// nhập tài khoản gmail
        pass: 'aaaaa', // mật khẩu gmail
    },
});

function generateOtp() {
    return crypto.randomInt(100000, 999999).toString();
}

router.post(`/upload`, upload.array("images"), async (req, res) => {
    imagesArr=[];

    try{
    
        for (let i = 0; i < req?.files?.length; i++) {

            const options = {
                use_filename: true,
                unique_filename: false,
                overwrite: false,
            };
    
            
            const result = await cloudinary.uploader.upload(req.files[i].path, options);
            imagesArr.push(result.secure_url);

            // Kiểm tra và xóa tệp trong thư mục uploads
            if (fs.existsSync(req.files[i].path)) {
                fs.unlinkSync(req.files[i].path);
            } else {
                console.warn(`File not found: ${req.files[i].path}`);
            }
        }


        let imagesUploaded = new ImageUpload({
            images: imagesArr,
        });

        imagesUploaded = await imagesUploaded.save();
        return res.status(200).json(imagesArr);

       

    }catch(error){
        console.log(error);
        return res.status(500).json({success: false, message: error.message});
    }

});

router.delete('/deleteImage', async (req, res) => {
    const imgUrl = req.query.img;

   // console.log(imgUrl)

    const urlArr = imgUrl.split('/');
    const image =  urlArr[urlArr.length-1];
  
    const imageName = image.split('.')[0];

    const response = await cloudinary.uploader.destroy(imageName, (error,result)=>{
       
    })

    if(response){
        res.status(200).send(response);
    }
      
});


router.post('/signup', async (req, res) => {
    const { email, password, fname, lname } = req.body;
    if (!email || !password || !fname || !lname) {
        return res.status(400).send('All fields are required.');
    }

    try {
        const existingUser = await UserModel.findOne({ email });
        if (existingUser) {
            return res.status(400).send('Email is already registered.');
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = new UserModel({
            email,
            password: hashedPassword,
            fname,
            lname,
            role: 'user',
        });

        await newUser.save();

        const token = jwt.sign({email:newUser.email, id: newUser._id}, process.env.JSON_WEB_TOKEN_SECRET_KEY);

        res.status(201).send({user:newUser,token:token,msg:'User registered successfully.'});
    } catch (error) {
        res.status(500).send('Error: ' + error.message);
    }
});

// User Login
router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).send('All fields are required.');
    }

    try {
        const user = await UserModel.findOne({ email });
        if (!user) {
            return res.status(404).send({error:true, msg:"User not found!"});
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).send({error:true,msg:"Invailid credentials"});
        }

        // if (!user.activate) {
        //     return res.status(400).send('Account not activated.');
        // }

        const token = jwt.sign({ id: user._id, role: user.role }, process.env.JSON_WEB_TOKEN_SECRET_KEY, { expiresIn: '7d' });

        res.status(200).json({
            user:user,
            token:token,
            msg:"user Authenticated"});
    } catch (error) {
        res.status(500).send('Error: ' + error.message);
    }
});

// Send OTP Email
router.post('/send-otp', async (req, res) => {
    const { email } = req.body;
    if (!email) {
        return res.status(400).send('Email is required.');
    }

    try {
        const user = await UserModel.findOne({ email });
        if (!user) {
            return res.status(404).send('User not found.');
        }

        const otp = generateOtp();
        const expiresAt = Date.now() + 120000; // OTP expires in 2 minutes

        user.storedOtp = otp;
        user.expiresAt = expiresAt;
        await user.save();

        // Send OTP email
        const mailOptions = {
            from: 'trongkhang1304@gmail.com',
            to: email,
            subject: 'Your OTP Code',
            text: `Your OTP code is: ${otp}. It will expire in 2 minutes.`,
        };

        await transporter.sendMail(mailOptions);

        res.status(200).send('OTP sent successfully.');
    } catch (error) {
        res.status(500).send('Error: ' + error.message);
    }
});

// Update User Profile
router.put('/profile/:uid', async (req, res) => {
    const { uid } = req.params;
    const { dateOfBirth, gender, weight, height, fname, lname } = req.body;

    if (!dateOfBirth || !gender || !weight || !height || !fname || !lname) {
        return res.status(400).send('All fields are required.');
    }

    try {
        const user = await UserModel.findById(uid);
        if (!user) {
            return res.status(404).send('User not found.');
        }

        user.dateOfBirth = dateOfBirth;
        user.gender = gender;
        user.weight = weight;
        user.height = height;
        user.fname = fname;
        user.lname = lname;

        await user.save();
        res.status(200).send('Profile updated successfully.');
    } catch (error) {
        res.status(500).send('Error: ' + error.message);
    }
});

router.post('/reset-password', async (req, res) => {
    const { email, otp, newPassword } = req.body;

    if (!email || !otp || !newPassword) {
        return res.status(400).send('All fields are required.');
    }

    try {
        const user = await UserModel.findOne({ email });
        if (!user) {
            return res.status(404).send('User not found.');
        }

        const { storedOtp, expiresAt } = user;
        if (Date.now() > expiresAt) {
            return res.status(400).send('OTP has expired.');
        }

        if (storedOtp !== otp) {
            return res.status(400).send('Invalid OTP.');
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        user.password = hashedPassword;
        await user.save();

        res.status(200).send('Password reset successfully.');
    } catch (error) {
        res.status(500).send('Error: ' + error.message);
    }
});

module.exports = router;