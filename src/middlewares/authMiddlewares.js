const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  // Get token from header
  const authHeader = req.header("Authorization");

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "الوصول مرفوض، لا يوجد توكن",
    });
  }

  // Extract token from "Bearer <token>"
  const token = authHeader.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "الوصول مرفوض، توكن غير صالح",
    });
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      message: "التوكن غير صالح أو منتهي الصلاحية",
    });
  }
};

module.exports = authMiddleware;
