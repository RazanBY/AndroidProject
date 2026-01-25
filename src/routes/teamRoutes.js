const express = require("express");
const router = express.Router();
const {
  getAllTeams,
  getAvailableTeams,
  getTeamById,
  addTeam,
  updateTeamStatus,
  updateTeam,
  deleteTeam,
} = require("../controllers/teamController");
const authMiddleware = require("../middlewares/authMiddlewares");

// Public routes (بدون مصادقة)
router.get("/", getAllTeams);
router.get("/available", getAvailableTeams);
router.get("/:id", getTeamById);

// Protected routes (للمدير فقط)
router.post("/", authMiddleware, addTeam);
router.put("/:id/status", authMiddleware, updateTeamStatus); // للموظفين أيضاً
router.put("/:id", authMiddleware, updateTeam);
router.delete("/:id", authMiddleware, deleteTeam);

module.exports = router;
