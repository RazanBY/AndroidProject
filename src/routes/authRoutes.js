const express = require("express");
const router = express.Router();
const {
  register,
  login,
  getUserProfile,
} = require("../controllers/authController");
const authMiddleware = require("../middlewares/authMiddlewares");

// Public routes
router.post("/register", register);
router.post("/login", login);

// Protected routes (require authentication)
router.get("/profile", authMiddleware, getUserProfile);

module.exports = router;
