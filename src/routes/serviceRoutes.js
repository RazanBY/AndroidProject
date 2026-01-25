const express = require("express");
const router = express.Router();
const {
  getAllServices,
  getServiceById,
  addService,
  updateService,
  deleteService,
} = require("../controllers/serviceController");
const authMiddleware = require("../middlewares/authMiddlewares");

// أي شخص يمكنه رؤية الخدمات (بدون تسجيل دخول)
router.get("/", getAllServices);
router.get("/:id", getServiceById);

// Routes التي تحتاج مصادقة
router.post("/", authMiddleware, addService);
router.put("/:id", authMiddleware, updateService);
router.delete("/:id", authMiddleware, deleteService);

module.exports = router;
