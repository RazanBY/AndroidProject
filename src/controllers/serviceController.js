const db = require("../config/database");

// جلب جميع الخدمات
const getAllServices = async (req, res) => {
  try {
    const [services] = await db.execute(
      "SELECT * FROM services ORDER BY price ASC",
    );

    res.json({
      success: true,
      count: services.length,
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

// جلب خدمة بواسطة الـID
const getServiceById = async (req, res) => {
  try {
    const { id } = req.params;

    const [services] = await db.execute("SELECT * FROM services WHERE id = ?", [
      id,
    ]);

    if (services.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الخدمة غير موجودة",
      });
    }

    res.json({
      success: true,
      service: services[0],
    });
  } catch (error) {
    console.error("Get service by ID error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب الخدمة",
    });
  }
};

const addService = async (req, res) => {
  try {
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { name, price, duration } = req.body;

    if (!name || !price || !duration) {
      return res.status(400).json({
        success: false,
        message: "جميع الحقول مطلوبة",
      });
    }

    const [result] = await db.execute(
      "INSERT INTO services (name, price, duration) VALUES (?, ?, ?)",
      [name, price, duration],
    );

    res.status(201).json({
      success: true,
      message: "تم إضافة الخدمة بنجاح",
      serviceId: result.insertId,
    });
  } catch (error) {
    console.error("Add service error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء إضافة الخدمة",
      error: error.message,
    });
  }
};

const updateService = async (req, res) => {
  try {
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;
    const { name, price, duration } = req.body;

    // إذا ما بعت ولا حقل، نرفض الطلب
    if (!name && !price && !duration) {
      return res.status(400).json({
        success: false,
        message: "لم يتم إرسال أي بيانات للتحديث",
      });
    }

    // بناء query ديناميكي بناءً على الحقول المرسلة
    let query = "UPDATE services SET";
    const values = [];
    const updates = [];

    if (name !== undefined) {
      updates.push(" name = ?");
      values.push(name);
    }

    if (price !== undefined) {
      updates.push(" price = ?");
      values.push(price);
    }

    if (duration !== undefined) {
      updates.push(" duration = ?");
      values.push(duration);
    }

    query += updates.join(",");
    query += " WHERE id = ?";
    values.push(id);

    // تنفيذ query
    const [result] = await db.execute(query, values);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "الخدمة غير موجودة",
      });
    }

    res.json({
      success: true,
      message: "تم تحديث الخدمة بنجاح",
      updatedFields: updates.length,
    });
  } catch (error) {
    console.error("Update service error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تحديث الخدمة",
      error: error.message,
    });
  }
};

// حذف خدمة (للمدير فقط)
const deleteService = async (req, res) => {
  try {
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;

    const [result] = await db.execute("DELETE FROM services WHERE id = ?", [
      id,
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "الخدمة غير موجودة",
      });
    }

    res.json({
      success: true,
      message: "تم حذف الخدمة بنجاح",
    });
  } catch (error) {
    console.error("Delete service error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء حذف الخدمة",
    });
  }
};

module.exports = {
  getAllServices,
  getServiceById,
  addService,
  updateService,
  deleteService,
};
