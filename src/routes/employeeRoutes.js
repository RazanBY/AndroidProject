const express = require("express");
const router = express.Router();
const {
  getAssignedJobs,
  updateJobStatus,
  completeJob,
  getEmployeeProfile,
} = require("../controllers/employeeController");
const authMiddleware = require("../middlewares/authMiddlewares");

// All employee routes require authentication
router.use(authMiddleware);

// Get assigned jobs
router.get("/jobs", getAssignedJobs);

// Update job status
router.post("/updateJobStatus", updateJobStatus);

// Complete job
router.post("/completeJob", completeJob);

// Get employee profile
router.get("/profile", getEmployeeProfile);

module.exports = router;

