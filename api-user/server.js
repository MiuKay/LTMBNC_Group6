const express = require('express');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const authRoute = require('./routes/authRoutes');
const cors = require('cors'); // Import cors

dotenv.config();
connectDB();

const app = express();
app.use(express.json());
app.use(cors()); // Enable CORS

app.use('/api/auth', authRoute);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
