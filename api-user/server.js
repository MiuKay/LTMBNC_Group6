const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const authRoute = require('./routes/authRoutes');
const cors = require('cors'); 
const workoutRoutes = require("./routes/workoutRoutes");
const tipRoutes = require("./routes/tipRoutes");

dotenv.config();
connectDB();

const app = express();
app.use(express.json());
app.use(cors()); 

app.use('/api/auth', authRoute);
app.use("/api/tips", tipRoutes);
app.use("/api/workouts", workoutRoutes);


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
