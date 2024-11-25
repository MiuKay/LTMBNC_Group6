const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
app.use(cors());
app.options('*', cors())

//middleware
app.use(bodyParser.json());
app.use(express.json());

const userRoutes = require('./routes/userRoute.js');
const imageUploadRoutes = require('./routes/imageUpload.js');
const exerciseRoutes = require("./routes/exerciseRoute.js");
const stepExerciseRoutes = require("./routes/stepExerciseRoute.js");
const tipRoutes = require("./routes/tipRoute.js");
const workoutScheduleRoutes = require("./routes/workoutScheduleRoute.js");
const toolRoutes = require('./routes/toolRoute.js');
const categoryWorkoutRoutes = require('./routes/categoryWorkoutRoute.js')
const workoutHistoryRoutes = require('./routes/workoutHistoryRoute.js');


app.use(`/api/user`,userRoutes);
app.use(`/uploads`,express.static("uploads"));
app.use(`/api/exercise`, exerciseRoutes);
app.use(`/api/stepExercise`, stepExerciseRoutes);
app.use(`/api/tip`, tipRoutes);
app.use(`/api/workoutSchedule`, workoutScheduleRoutes);
app.use(`/api/imageUpload`, imageUploadRoutes);
app.use(`/api/categoryWorkout`, categoryWorkoutRoutes);
app.use(`/api/tool`, toolRoutes);
app.use(`/api/workoutHistories`, workoutHistoryRoutes);


mongoose.connect(process.env.DATABASE_CONNECT_STRING, {
    useNewurlParser: true,
    useUnifiedTopology: true
}).then(() => {
    console.log('Database Connection is ready ...')
    app.listen(process.env.PORT, () => {
        console.log(`Server is running http://localhost:${process.env.PORT}`)
    })
})

