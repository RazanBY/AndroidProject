const express = require("express");
const router = express.Router();
const {
  getWalletBalance,
  depositToWallet,
  getTransactions,
  payFromWallet,
} = require("../controllers/walletController");
const authMiddleware = require("../middlewares/authMiddlewares");

// كل الطرق تحتاج مصادقة
router.use(authMiddleware);

router.get("/balance", getWalletBalance);
router.post("/deposit", depositToWallet);
router.get("/transactions", getTransactions);
router.post("/pay", payFromWallet);

module.exports = router;
