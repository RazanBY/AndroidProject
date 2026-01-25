const db = require("../config/database");

// Get assigned jobs for employee
const getAssignedJobs = async (req, res) => {
  try {
    const employeeId = req.user.userId;
    const userType = req.user.userType;

    // Check if user is employee
    if (userType !== "employee") {
      return res.status(403).json({
        success: false,
        message: "غير مصرح لك بالوصول",
      });
    }

    // Get team_id for this employee
    const [employees] = await db.execute(
      "SELECT team_id FROM users WHERE id = ?",
      [employeeId]
    );

    if (employees.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الموظف غير موجود",
      });
    }

    const teamId = employees[0].team_id;

    // Get bookings assigned to this team
    const [bookings] = await db.execute(
      `SELECT 
        b.id,
        b.booking_date as date,
        b.location,
        b.lat,
        b.lng,
        b.status,
        b.total_price as price,
        u.name as customerName,
        c.model as carModel,
        c.plate_number as carPlate,
        s.name as serviceType,
        CONCAT(b.location, ', ', COALESCE(b.address, '')) as address
      FROM bookings b
      JOIN users u ON b.user_id = u.id
      JOIN cars c ON b.car_id = c.id
      JOIN services s ON b.service_id = s.id
      WHERE b.team_id = ? AND b.status IN ('pending', 'in_progress')
      ORDER BY b.booking_date ASC`,
      [teamId]
    );

    // Format time from booking_date
    const formattedBookings = bookings.map((booking) => {
      const date = new Date(booking.date);
      const time = date.toLocaleTimeString("en-US", {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      });
      const dateStr = date.toLocaleDateString("en-US", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
      });

      return {
        id: booking.id.toString(),
        customerName: booking.customerName,
        carModel: booking.carModel,
        carPlate: booking.carPlate,
        serviceType: booking.serviceType,
        location: booking.location,
        address: booking.address || booking.location,
        status: booking.status === "pending" ? "Pending" : "In Progress",
        date: dateStr,
        time: time,
        price: parseFloat(booking.price),
        employeeId: employeeId.toString(),
        teamId: teamId ? teamId.toString() : null,
      };
    });

    res.json(formattedBookings);
  } catch (error) {
    console.error("Get assigned jobs error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الوظائف",
      error: error.message,
    });
  }
};

// Update job status
const updateJobStatus = async (req, res) => {
  try {
    const employeeId = req.user.userId;
    const userType = req.user.userType;
    const { jobId, status } = req.body;

    if (userType !== "employee") {
      return res.status(403).json({
        success: false,
        message: "غير مصرح لك بالوصول",
      });
    }

    // Map status to database values
    const statusMap = {
      Pending: "pending",
      "In Progress": "in_progress",
      Completed: "completed",
      Cancelled: "cancelled",
    };

    const dbStatus = statusMap[status] || status.toLowerCase();

    // Verify the booking belongs to employee's team
    const [employees] = await db.execute(
      "SELECT team_id FROM users WHERE id = ?",
      [employeeId]
    );

    if (employees.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الموظف غير موجود",
      });
    }

    const teamId = employees[0].team_id;

    const [bookings] = await db.execute(
      "SELECT id FROM bookings WHERE id = ? AND team_id = ?",
      [jobId, teamId]
    );

    if (bookings.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الوظيفة غير موجودة أو غير مخصصة لك",
      });
    }

    await db.execute("UPDATE bookings SET status = ? WHERE id = ?", [
      dbStatus,
      jobId,
    ]);

    // If completed, free up the team
    if (dbStatus === "completed") {
      await db.execute("UPDATE teams SET status = 'available' WHERE id = ?", [
        teamId,
      ]);
    }

    res.json({
      success: true,
      message: "تم تحديث حالة الوظيفة بنجاح",
    });
  } catch (error) {
    console.error("Update job status error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في تحديث حالة الوظيفة",
      error: error.message,
    });
  }
};

// Complete job with completion time
const completeJob = async (req, res) => {
  try {
    const employeeId = req.user.userId;
    const userType = req.user.userType;
    const { jobId, completionDate, completionTime } = req.body;

    if (userType !== "employee") {
      return res.status(403).json({
        success: false,
        message: "غير مصرح لك بالوصول",
      });
    }

    // Verify the booking belongs to employee's team
    const [employees] = await db.execute(
      "SELECT team_id FROM users WHERE id = ?",
      [employeeId]
    );

    if (employees.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الموظف غير موجود",
      });
    }

    const teamId = employees[0].team_id;

    const [bookings] = await db.execute(
      "SELECT id FROM bookings WHERE id = ? AND team_id = ?",
      [jobId, teamId]
    );

    if (bookings.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الوظيفة غير موجودة أو غير مخصصة لك",
      });
    }

    // Update booking status and completion time
    await db.execute(
      "UPDATE bookings SET status = 'completed', completed_at = NOW() WHERE id = ?",
      [jobId]
    );

    // Free up the team
    await db.execute("UPDATE teams SET status = 'available' WHERE id = ?", [
      teamId,
    ]);

    res.json({
      success: true,
      message: "تم إكمال الوظيفة بنجاح",
    });
  } catch (error) {
    console.error("Complete job error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في إكمال الوظيفة",
      error: error.message,
    });
  }
};

// Get employee profile with statistics
const getEmployeeProfile = async (req, res) => {
  try {
    const employeeId = req.user.userId;
    const userType = req.user.userType;

    if (userType !== "employee") {
      return res.status(403).json({
        success: false,
        message: "غير مصرح لك بالوصول",
      });
    }

    // Get employee info
    const [users] = await db.execute(
      `SELECT u.id, u.name, u.email, u.phone, u.team_id, t.team_name
       FROM users u
       LEFT JOIN teams t ON u.team_id = t.id
       WHERE u.id = ?`,
      [employeeId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الموظف غير موجود",
      });
    }

    const employee = users[0];

    // Get total completed jobs
    const [stats] = await db.execute(
      `SELECT COUNT(*) as totalJobs 
       FROM bookings 
       WHERE team_id = ? AND status = 'completed'`,
      [employee.team_id]
    );

    const totalJobsCompleted = stats[0]?.totalJobs || 0;

    res.json({
      success: true,
      employee: {
        id: employee.id.toString(),
        name: employee.name,
        email: employee.email,
        phone: employee.phone,
        teamId: employee.team_id ? employee.team_id.toString() : null,
        teamName: employee.team_name,
        totalJobsCompleted: totalJobsCompleted,
      },
    });
  } catch (error) {
    console.error("Get employee profile error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات الموظف",
      error: error.message,
    });
  }
};

module.exports = {
  getAssignedJobs,
  updateJobStatus,
  completeJob,
  getEmployeeProfile,
};

