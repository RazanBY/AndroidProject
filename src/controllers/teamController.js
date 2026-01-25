const db = require("../config/database");

// 1. جلب جميع الفرق
const getAllTeams = async (req, res) => {
  try {
    const [teams] = await db.execute(
      "SELECT * FROM teams ORDER BY status DESC, id ASC",
    );

    res.json({
      success: true,
      count: teams.length,
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

// 2. جلب الفرق المتاحة فقط
const getAvailableTeams = async (req, res) => {
  try {
    const [teams] = await db.execute(
      "SELECT * FROM teams WHERE status = 'available'",
    );

    res.json({
      success: true,
      count: teams.length,
      teams: teams,
    });
  } catch (error) {
    console.error("Get available teams error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الفرق المتاحة",
    });
  }
};

// 3. إضافة فريق جديد (للمدير فقط)
const addTeam = async (req, res) => {
  try {
    const { team_name, car_number } = req.body;

    // التحقق من البيانات
    if (!team_name || !car_number) {
      return res.status(400).json({
        success: false,
        message: "اسم الفريق ورقم السيارة مطلوبان",
      });
    }

    // إضافة الفريق
    const [result] = await db.execute(
      "INSERT INTO teams (team_name, car_number, status) VALUES (?, ?, ?)",
      [team_name, car_number, "available"],
    );

    // جلب الفريق المضاف
    const [newTeam] = await db.execute("SELECT * FROM teams WHERE id = ?", [
      result.insertId,
    ]);

    res.status(201).json({
      success: true,
      message: "تم إضافة الفريق بنجاح",
      team: newTeam[0],
    });
  } catch (error) {
    console.error("Add team error:", error);

    // إذا كان الخطأ بسبب تكرار رقم السيارة
    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        success: false,
        message: "رقم السيارة مستخدم بالفعل",
      });
    }

    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء إضافة الفريق",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 4. تحديث حالة الفريق (للعاملين والمدير)
const updateTeamStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // التحقق من البيانات
    if (!status || !["available", "busy"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "الحالة يجب أن تكون available أو busy",
      });
    }

    // التحقق من وجود الفريق
    const [teamCheck] = await db.execute("SELECT id FROM teams WHERE id = ?", [
      id,
    ]);

    if (teamCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الفريق غير موجود",
      });
    }

    // تحديث الحالة
    const [result] = await db.execute(
      "UPDATE teams SET status = ? WHERE id = ?",
      [status, id],
    );

    // جلب البيانات المحدثة
    const [updatedTeam] = await db.execute("SELECT * FROM teams WHERE id = ?", [
      id,
    ]);

    res.json({
      success: true,
      message: `تم تحديث حالة الفريق إلى ${status === "available" ? "متاح" : "مشغول"}`,
      team: updatedTeam[0],
    });
  } catch (error) {
    console.error("Update team status error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تحديث حالة الفريق",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 5. حذف فريق (للمدير فقط)
const deleteTeam = async (req, res) => {
  try {
    const { id } = req.params;

    // التحقق من وجود الفريق
    const [teamCheck] = await db.execute("SELECT id FROM teams WHERE id = ?", [
      id,
    ]);

    if (teamCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الفريق غير موجود",
      });
    }

    // التحقق إذا الفريق مشغول بحجز
    const [activeBookings] = await db.execute(
      'SELECT id FROM bookings WHERE team_id = ? AND status IN ("confirmed", "in_progress")',
      [id],
    );

    if (activeBookings.length > 0) {
      return res.status(400).json({
        success: false,
        message: "لا يمكن حذف الفريق لأنه مشغول بحجز نشط",
      });
    }

    // تحديث الحجوزات المرتبطة بهذا الفريق
    await db.execute("UPDATE bookings SET team_id = NULL WHERE team_id = ?", [
      id,
    ]);

    // حذف الفريق
    const [result] = await db.execute("DELETE FROM teams WHERE id = ?", [id]);

    res.json({
      success: true,
      message: "تم حذف الفريق بنجاح",
      deletedId: parseInt(id),
    });
  } catch (error) {
    console.error("Delete team error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء حذف الفريق",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 6. تحديث بيانات الفريق (للمدير فقط)
const updateTeam = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    // إذا الجسم فارغ
    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: "لم يتم إرسال أي بيانات للتحديث",
      });
    }

    // الحقول المسموح بها
    const allowedFields = ["team_name", "car_number"];
    const fieldsToUpdate = {};

    // تصفية الحقول المسموح بها
    Object.keys(updates).forEach((key) => {
      if (allowedFields.includes(key) && updates[key] !== undefined) {
        fieldsToUpdate[key] = updates[key];
      }
    });

    if (Object.keys(fieldsToUpdate).length === 0) {
      return res.status(400).json({
        success: false,
        message: "لم يتم إرسال أي بيانات صالحة للتحديث",
      });
    }

    // التحقق من وجود الفريق
    const [teamCheck] = await db.execute("SELECT id FROM teams WHERE id = ?", [
      id,
    ]);

    if (teamCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الفريق غير موجود",
      });
    }

    // بناء query ديناميكي
    const setClause = Object.keys(fieldsToUpdate)
      .map((field) => `${field} = ?`)
      .join(", ");

    const values = Object.values(fieldsToUpdate);
    values.push(id);

    const query = `UPDATE teams SET ${setClause} WHERE id = ?`;

    await db.execute(query, values);

    // جلب البيانات المحدثة
    const [updatedTeam] = await db.execute("SELECT * FROM teams WHERE id = ?", [
      id,
    ]);

    res.json({
      success: true,
      message: "تم تحديث بيانات الفريق بنجاح",
      team: updatedTeam[0],
      updatedFields: Object.keys(fieldsToUpdate),
    });
  } catch (error) {
    console.error("Update team error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تحديث بيانات الفريق",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 7. جلب فريق بواسطة ID
const getTeamById = async (req, res) => {
  try {
    const { id } = req.params;

    const [teams] = await db.execute("SELECT * FROM teams WHERE id = ?", [id]);

    if (teams.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الفريق غير موجود",
      });
    }

    res.json({
      success: true,
      team: teams[0],
    });
  } catch (error) {
    console.error("Get team by ID error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات الفريق",
    });
  }
};

// تصدير جميع الدوال
module.exports = {
  getAllTeams,
  getAvailableTeams,
  getTeamById,
  addTeam,
  updateTeamStatus,
  updateTeam,
  deleteTeam,
};
