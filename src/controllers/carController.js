const db = require("../config/database");

// 1. إضافة سيارة جديدة للمستخدم
const addCar = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { car_model, plate_number, color } = req.body;

    // التحقق من البيانات المطلوبة
    if (!car_model || !plate_number) {
      return res.status(400).json({
        success: false,
        message: "موديل السيارة ورقم اللوحة مطلوبان",
      });
    }

    // التحقق من أن رقم اللوحة ليس مستخدم من قبل لنفس المستخدم
    const [existing] = await db.execute(
      "SELECT id FROM cars WHERE plate_number = ? AND user_id = ?",
      [plate_number, userId],
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: "رقم اللوحة مستخدم بالفعل لهذا المستخدم",
      });
    }

    // إضافة السيارة
    const [result] = await db.execute(
      "INSERT INTO cars (user_id, car_model, plate_number, color) VALUES (?, ?, ?, ?)",
      [userId, car_model, plate_number, color || ""],
    );

    // جلب السيارة المضاف
    const [newCar] = await db.execute("SELECT * FROM cars WHERE id = ?", [
      result.insertId,
    ]);

    res.status(201).json({
      success: true,
      message: "تم إضافة السيارة بنجاح",
      car: newCar[0],
    });
  } catch (error) {
    console.error("Add car error:", error);

    // إذا كان الخطأ بسبب تكرار رقم اللوحة (على مستوى قاعدة البيانات)
    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        success: false,
        message: "رقم اللوحة مستخدم بالفعل",
      });
    }

    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء إضافة السيارة",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 2. جلب سيارات المستخدم
const getUserCars = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [cars] = await db.execute(
      "SELECT * FROM cars WHERE user_id = ? ORDER BY id DESC",
      [userId],
    );

    res.json({
      success: true,
      count: cars.length,
      cars: cars,
    });
  } catch (error) {
    console.error("Get user cars error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب السيارات",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 3. تحديث بيانات سيارة
const updateCar = async (req, res) => {
  try {
    const userId = req.user.userId;
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
    const allowedFields = ["car_model", "plate_number", "color"];
    const fieldsToUpdate = {};

    // تصفية الحقول المسموح بها فقط
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

    // التحقق من أن السيارة تخص المستخدم
    const [carCheck] = await db.execute(
      "SELECT id FROM cars WHERE id = ? AND user_id = ?",
      [id, userId],
    );

    if (carCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "السيارة غير موجودة أو لا تخصك",
      });
    }

    // إذا كان التحديث يشمل رقم اللوحة، تحقق من عدم التكرار
    if (fieldsToUpdate.plate_number) {
      const [existing] = await db.execute(
        "SELECT id FROM cars WHERE plate_number = ? AND user_id = ? AND id != ?",
        [fieldsToUpdate.plate_number, userId, id],
      );

      if (existing.length > 0) {
        return res.status(400).json({
          success: false,
          message: "رقم اللوحة مستخدم بالفعل",
        });
      }
    }

    // بناء الـquery ديناميكياً
    const setClause = Object.keys(fieldsToUpdate)
      .map((field) => `${field} = ?`)
      .join(", ");

    const values = Object.values(fieldsToUpdate);
    values.push(id, userId);

    const query = `UPDATE cars SET ${setClause} WHERE id = ? AND user_id = ?`;

    await db.execute(query, values);

    // جلب البيانات المحدثة
    const [updatedCar] = await db.execute("SELECT * FROM cars WHERE id = ?", [
      id,
    ]);

    res.json({
      success: true,
      message: "تم تحديث بيانات السيارة بنجاح",
      car: updatedCar[0],
      updatedFields: Object.keys(fieldsToUpdate),
    });
  } catch (error) {
    console.error("Update car error:", error);

    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        success: false,
        message: "رقم اللوحة مستخدم بالفعل",
      });
    }

    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تحديث السيارة",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 4. حذف سيارة
const deleteCar = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    // التحقق من وجود السيارة وتعلقها بالمستخدم
    const [carCheck] = await db.execute(
      "SELECT id FROM cars WHERE id = ? AND user_id = ?",
      [id, userId],
    );

    if (carCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "السيارة غير موجودة أو لا تخصك",
      });
    }

    // التحقق إذا السيارة مرتبطة بحجوزات نشطة
    const [activeBookings] = await db.execute(
      'SELECT id FROM bookings WHERE car_id = ? AND status IN ("pending", "confirmed", "in_progress")',
      [id],
    );

    if (activeBookings.length > 0) {
      return res.status(400).json({
        success: false,
        message: "لا يمكن حذف السيارة لأنها مرتبطة بحجوزات نشطة",
      });
    }

    // حذف السيارة
    const [result] = await db.execute(
      "DELETE FROM cars WHERE id = ? AND user_id = ?",
      [id, userId],
    );

    res.json({
      success: true,
      message: "تم حذف السيارة بنجاح",
      deletedId: parseInt(id),
    });
  } catch (error) {
    console.error("Delete car error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء حذف السيارة",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

// 5. جلب سيارة محددة بواسطة ID
const getCarById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const [cars] = await db.execute(
      "SELECT * FROM cars WHERE id = ? AND user_id = ?",
      [id, userId],
    );

    if (cars.length === 0) {
      return res.status(404).json({
        success: false,
        message: "السيارة غير موجودة أو لا تخصك",
      });
    }

    res.json({
      success: true,
      car: cars[0],
    });
  } catch (error) {
    console.error("Get car by ID error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات السيارة",
    });
  }
};

// 6. جلب عدد سيارات المستخدم
const getCarCount = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [result] = await db.execute(
      "SELECT COUNT(*) as count FROM cars WHERE user_id = ?",
      [userId],
    );

    res.json({
      success: true,
      count: result[0].count,
    });
  } catch (error) {
    console.error("Get car count error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب عدد السيارات",
    });
  }
};

// تصدير جميع الدوال
module.exports = {
  addCar,
  getUserCars,
  updateCar,
  deleteCar,
  getCarById,
  getCarCount,
};
