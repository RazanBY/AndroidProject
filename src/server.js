const express = require("express");
const cors = require("cors");
require("dotenv").config();

// Import routes
const authRoutes = require("./routes/authRoutes");
const bookingRoutes = require("./routes/bookingRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Home route
app.get("/", (req, res) => {
  res.json({
    message: "🚗 Car Wash API",
    version: "1.0.0",
    endpoints: {
      auth: "/api/auth",
      bookings: "/api/bookings",
    },
  });
});

// API Routes
app.use("/api/auth", authRoutes);
app.use("/api/bookings", bookingRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "الرابط غير موجود",
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "حدث خطأ في السيرفر",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`✅ Server is running on port ${PORT}`);
  console.log(`📡 API URL: http://localhost:${PORT}`);
});
