const db = require("../config/database");

const getAllServices = async (req, res) => {
  try {
    const [services] = await db.execute(
      "SELECT * FROM services ORDER BY price ASC"
    );

    res.json({
      success: true,
      services: services,
    });
  } catch (error) {
    console.error("Get services error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الخدمات",
    });
  }
};

const createBooking = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { car_id, service_id, booking_date, location, lat, lng } = req.body;

    const [services] = await db.execute(
      "SELECT price FROM services WHERE id = ?",
      [service_id]
    );

    if (services.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الخدمة غير موجودة",
      });
    }

    const servicePrice = services[0].price;

    const [teams] = await db.execute(
      "SELECT id FROM teams WHERE status = 'available' LIMIT 1"
    );

    let teamId = null;
    if (teams.length > 0) {
      teamId = teams[0].id;
    }

    const [result] = await db.execute(
      `INSERT INTO bookings 
            (user_id, car_id, service_id, team_id, booking_date, location, lat, lng, total_price) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        car_id,
        service_id,
        teamId,
        booking_date,
        location,
        lat,
        lng,
        servicePrice,
      ]
    );

    if (teamId) {
      await db.execute("UPDATE teams SET status = 'busy' WHERE id = ?", [
        teamId,
      ]);
    }

    res.status(201).json({
      success: true,
      message: "تم إنشاء الحجز بنجاح",
      bookingId: result.insertId,
    });
  } catch (error) {
    console.error("Create booking error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء إنشاء الحجز",
      error: error.message,
    });
  }
};

const getUserBookings = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [bookings] = await db.execute(
      `SELECT b.*, s.name as service_name, s.price, t.team_name, t.car_number 
             FROM bookings b
             JOIN services s ON b.service_id = s.id
             LEFT JOIN teams t ON b.team_id = t.id
             WHERE b.user_id = ?
             ORDER BY b.booking_date DESC`,
      [userId]
    );

    res.json({
      success: true,
      bookings: bookings,
    });
  } catch (error) {
    console.error("Get bookings error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الحجوزات",
    });
  }
};

const getAvailableTeams = async (req, res) => {
  try {
    const [teams] = await db.execute(
      "SELECT * FROM teams WHERE status = 'available'"
    );

    res.json({
      success: true,
      teams: teams,
    });
  } catch (error) {
    console.error("Get teams error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الفرق",
    });
  }
};

module.exports = {
  getAllServices,
  createBooking,
  getUserBookings,
  getAvailableTeams,
};
