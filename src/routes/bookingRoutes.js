const express = require("express");
const router = express.Router();
const {
  getAllServices,
  createBooking,
  getUserBookings,
  getAvailableTeams,
} = require("../controllers/bookingController");
const authMiddleware = require("../middlewares/authMiddlewares");

router.use(authMiddleware);

router.get("/services", getAllServices);
router.post("/create", createBooking);
router.get("/my-bookings", getUserBookings);
router.get("/teams", getAvailableTeams);

module.exports = router;
