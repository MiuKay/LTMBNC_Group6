var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var cors = require('cors');
var mongoose = require('mongoose');

// Import các route API
const userRoutes = require('./routes/userRoutes');
const exerciseRoutes = require('./routes/exerciseRoutes');
const stepExerciseRoutes = require('./routes/stepExerciseRoutes');
const tipRoutes = require('./routes/tipRoutes');

// Khởi tạo ứng dụng Express
var app = express();

// Sử dụng middleware
app.use(cors()); // Cấu hình CORS
app.use(logger('dev')); // Log các yêu cầu HTTP
app.use(express.json()); // Middleware để xử lý JSON
app.use(express.urlencoded({ extended: false })); // Middleware để xử lý dữ liệu URL encoded
app.use(cookieParser()); // Middleware để xử lý cookies
app.use(express.static(path.join(__dirname, 'public'))); // Cấu hình static files (nếu có)

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/fitnessApp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
    .then(() => console.log('MongoDB connected'))
    .catch((err) => console.error('MongoDB connection error: ', err));

// Cấu hình các route API
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/exercises', exerciseRoutes);
app.use('/api/v1/stepExercises', stepExerciseRoutes);
app.use('/api/v1/tips', tipRoutes);

// Catch 404 errors và chuyển tới handler lỗi
app.use(function(req, res, next) {
  next(createError(404));
});

// Error handler
app.use(function(err, req, res, next) {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  res.status(err.status || 500);
  res.render('error'); // Hiển thị trang lỗi (nếu sử dụng view engine)
});

module.exports = app;
