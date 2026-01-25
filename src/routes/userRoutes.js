const express = require("express");
const router = express.Router();
const {
  getAllUsers,
  getUserById,
  addEmployee,
  updateUser,
  changeUserType,
  getSystemStats,
  deleteUser,
  adjustWalletBalance,
} = require("../controllers/userController");
const authMiddleware = require("../middlewares/authMiddlewares");

// كل الطرق تحتاج مصادقة كمدير
router.use(authMiddleware);

// GET routes
router.get("/", getAllUsers);
router.get("/stats", getSystemStats);
router.get("/:id", getUserById);

// POST routes
router.post("/", addEmployee); // إضافة موظف/مدير جديد
router.post("/:id/wallet/adjust", adjustWalletBalance); // تعديل رصيد محفظة

// PUT routes
router.put("/:id", updateUser); // تحديث بيانات مستخدم
router.put("/:id/type", changeUserType); // تغيير نوع المستخدم

// DELETE routes
router.delete("/:id", deleteUser); // حذف مستخدم

module.exports = router;
