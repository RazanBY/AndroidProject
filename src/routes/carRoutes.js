const express = require("express");
const router = express.Router();
const {
  addCar,
  getUserCars,
  updateCar,
  deleteCar,
} = require("../controllers/carController");
const authMiddleware = require("../middlewares/authMiddlewares");

// كل الطرق تحتاج مصادقة
router.use(authMiddleware);

router.get("/", getUserCars);
router.post("/", addCar);
router.put("/:id", updateCar);
router.delete("/:id", deleteCar);

module.exports = router;
