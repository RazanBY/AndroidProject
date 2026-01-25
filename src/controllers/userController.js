const db = require("../config/database");
const bcrypt = require("bcryptjs");

// 1. جلب جميع المستخدمين (للمدير فقط)
const getAllUsers = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const [users] = await db.execute(
      `SELECT 
        id,
        name,
        email,
        phone,
        user_type,
        wallet_balance,
        created_at
      FROM users 
      ORDER BY created_at DESC`,
    );

    res.json({
      success: true,
      users: users,
    });
  } catch (error) {
    console.error("Get all users error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب المستخدمين",
    });
  }
};

// 2. جلب مستخدم بواسطة ID (للمدير فقط)
const getUserById = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;

    const [users] = await db.execute(
      `SELECT 
        id,
        name,
        email,
        phone,
        user_type,
        wallet_balance,
        created_at
      FROM users 
      WHERE id = ?`,
      [id],
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    // جلب سيارات المستخدم إذا كان عميلاً
    let cars = [];
    if (users[0].user_type === "customer") {
      const [userCars] = await db.execute(
        "SELECT id, car_model, plate_number, color FROM cars WHERE user_id = ?",
        [id],
      );
      cars = userCars;
    }

    // جلب حجوزات المستخدم
    const [bookings] = await db.execute(
      `SELECT 
        b.id,
        b.booking_date,
        b.location,
        b.status,
        b.total_price,
        b.payment_status,
        s.name as service_name
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      WHERE b.user_id = ?
      ORDER BY b.booking_date DESC`,
      [id],
    );

    const user = users[0];
    user.cars = cars;
    user.bookings = bookings;

    res.json({
      success: true,
      user: user,
    });
  } catch (error) {
    console.error("Get user by ID error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات المستخدم",
    });
  }
};

// 3. إضافة موظف جديد (للمدير فقط)
const addEmployee = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { name, email, password, phone, user_type } = req.body;

    // التحقق من البيانات
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: "الاسم، الإيميل، وكلمة المرور مطلوبة",
      });
    }

    // التحقق من صحة نوع المستخدم
    if (user_type && !["employee", "manager"].includes(user_type)) {
      return res.status(400).json({
        success: false,
        message: "نوع المستخدم يجب أن يكون employee أو manager",
      });
    }

    // التحقق من أن الإيميل غير مستخدم
    const [existing] = await db.execute(
      "SELECT id FROM users WHERE email = ?",
      [email],
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: "البريد الإلكتروني مستخدم بالفعل",
      });
    }

    // تشفير كلمة المرور
    const hashedPassword = await bcrypt.hash(password, 10);

    // إضافة المستخدم
    const [result] = await db.execute(
      "INSERT INTO users (name, email, password, phone, user_type) VALUES (?, ?, ?, ?, ?)",
      [name, email, hashedPassword, phone || null, user_type || "employee"],
    );

    res.status(201).json({
      success: true,
      message: `تم إضافة ${user_type === "manager" ? "مدير" : "موظف"} جديد بنجاح`,
      userId: result.insertId,
    });
  } catch (error) {
    console.error("Add employee error:", error);

    if (error.code === "ER_DUP_ENTRY") {
      return res.status(400).json({
        success: false,
        message: "البريد الإلكتروني مستخدم بالفعل",
      });
    }

    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء إضافة المستخدم",
    });
  }
};

// 4. تحديث بيانات مستخدم (للمدير فقط)
const updateUser = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;
    const { name, phone, user_type, wallet_balance } = req.body;

    // التحقق من وجود المستخدم
    const [userCheck] = await db.execute("SELECT id FROM users WHERE id = ?", [
      id,
    ]);

    if (userCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    // التحقق من صحة نوع المستخدم إذا تم إرساله
    if (user_type && !["customer", "employee", "manager"].includes(user_type)) {
      return res.status(400).json({
        success: false,
        message: "نوع المستخدم غير صالح",
      });
    }

    // بناء query ديناميكي
    let query = "UPDATE users SET";
    const values = [];
    const updates = [];

    if (name !== undefined) {
      updates.push(" name = ?");
      values.push(name);
    }

    if (phone !== undefined) {
      updates.push(" phone = ?");
      values.push(phone);
    }

    if (user_type !== undefined) {
      updates.push(" user_type = ?");
      values.push(user_type);
    }

    if (wallet_balance !== undefined) {
      updates.push(" wallet_balance = ?");
      values.push(wallet_balance);
    }

    // إذا ما في تحديثات
    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: "لم يتم إرسال أي بيانات للتحديث",
      });
    }

    query += updates.join(",");
    query += " WHERE id = ?";
    values.push(id);

    await db.execute(query, values);

    res.json({
      success: true,
      message: "تم تحديث بيانات المستخدم بنجاح",
    });
  } catch (error) {
    console.error("Update user error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تحديث بيانات المستخدم",
    });
  }
};

// 5. تغيير نوع المستخدم (للمدير فقط)
const changeUserType = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;
    const { user_type } = req.body;

    // التحقق من البيانات
    if (
      !user_type ||
      !["customer", "employee", "manager"].includes(user_type)
    ) {
      return res.status(400).json({
        success: false,
        message: "نوع المستخدم غير صالح",
      });
    }

    // منع المدير من تغيير نوعه الخاص
    if (parseInt(id) === req.user.userId) {
      return res.status(400).json({
        success: false,
        message: "لا يمكن تغيير صلاحياتك الخاصة",
      });
    }

    // تحديث نوع المستخدم
    const [result] = await db.execute(
      "UPDATE users SET user_type = ? WHERE id = ?",
      [user_type, id],
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    res.json({
      success: true,
      message: `تم تغيير نوع المستخدم إلى ${user_type === "customer" ? "عميل" : user_type === "employee" ? "موظف" : "مدير"} بنجاح`,
    });
  } catch (error) {
    console.error("Change user type error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تغيير نوع المستخدم",
    });
  }
};

// 6. جلب إحصائيات النظام (للمدير فقط)
const getSystemStats = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    // جلب إحصائيات المستخدمين
    const [userStats] = await db.execute(
      `SELECT 
        user_type,
        COUNT(*) as count
      FROM users 
      GROUP BY user_type`,
    );

    // جلب إحصائيات الحجوزات
    const [bookingStats] = await db.execute(
      `SELECT 
        COUNT(*) as total_bookings,
        SUM(total_price) as total_revenue,
        AVG(total_price) as avg_price
      FROM bookings 
      WHERE payment_status = 'paid'`,
    );

    // جلب إحصائيات اليوم
    const [todayStats] = await db.execute(
      `SELECT 
        COUNT(*) as today_bookings,
        SUM(total_price) as today_revenue
      FROM bookings 
      WHERE DATE(created_at) = CURDATE()`,
    );

    res.json({
      success: true,
      stats: {
        users: userStats,
        bookings: {
          total: bookingStats[0].total_bookings || 0,
          revenue: bookingStats[0].total_revenue || 0,
          average: bookingStats[0].avg_price || 0,
        },
        today: {
          bookings: todayStats[0].today_bookings || 0,
          revenue: todayStats[0].today_revenue || 0,
        },
      },
    });
  } catch (error) {
    console.error("Get system stats error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب إحصائيات النظام",
    });
  }
};

// 7. حذف مستخدم (للمدير فقط)
const deleteUser = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;

    // منع حذف المدير لنفسه
    if (parseInt(id) === req.user.userId) {
      return res.status(400).json({
        success: false,
        message: "لا يمكن حذف حسابك الخاص",
      });
    }

    // حذف المستخدم
    const [result] = await db.execute("DELETE FROM users WHERE id = ?", [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    res.json({
      success: true,
      message: "تم حذف المستخدم بنجاح",
    });
  } catch (error) {
    console.error("Delete user error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء حذف المستخدم",
    });
  }
};

// 8. تعديل رصيد محفظة مستخدم (للمدير فقط)
const adjustWalletBalance = async (req, res) => {
  try {
    // التحقق من أن المستخدم مدير
    if (req.user.userType !== "manager") {
      return res.status(403).json({
        success: false,
        message: "غير مسموح، هذه الصلاحية للمدير فقط",
      });
    }

    const { id } = req.params;
    const { amount, operation } = req.body;

    // التحقق من البيانات
    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: "المبلغ غير صالح",
      });
    }

    if (!operation || !["add", "subtract"].includes(operation)) {
      return res.status(400).json({
        success: false,
        message: "العملية يجب أن تكون add أو subtract",
      });
    }

    // التحقق من وجود المستخدم
    const [userCheck] = await db.execute(
      "SELECT id, wallet_balance FROM users WHERE id = ?",
      [id],
    );

    if (userCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    const currentBalance = userCheck[0].wallet_balance;
    let newBalance;

    // حساب الرصيد الجديد
    if (operation === "add") {
      newBalance = currentBalance + parseFloat(amount);
    } else {
      // التحقق من أن الرصيد لا يصبح سالب
      if (currentBalance < amount) {
        return res.status(400).json({
          success: false,
          message: "رصيد المستخدم غير كافي للخصم",
          currentBalance: currentBalance,
        });
      }
      newBalance = currentBalance - parseFloat(amount);
    }

    // تحديث الرصيد
    await db.execute("UPDATE users SET wallet_balance = ? WHERE id = ?", [
      newBalance,
      id,
    ]);

    // تسجيل العملية في transactions إذا كان هناك table
    try {
      await db.execute(
        "INSERT INTO transactions (user_id, amount, type) VALUES (?, ?, ?)",
        [id, amount, operation === "add" ? "deposit" : "payment"],
      );
    } catch (error) {
      console.log(
        "Note: Transactions table might not exist, skipping transaction log",
      );
    }

    res.json({
      success: true,
      message: `تم ${operation === "add" ? "إضافة" : "خصم"} ${amount} دينار ${operation === "add" ? "إلى" : "من"} المحفظة بنجاح`,
      previousBalance: currentBalance,
      newBalance: newBalance,
    });
  } catch (error) {
    console.error("Adjust wallet balance error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تعديل رصيد المحفظة",
    });
  }
};

// تصدير جميع الدوال
module.exports = {
  getAllUsers,
  getUserById,
  addEmployee,
  updateUser,
  changeUserType,
  getSystemStats,
  deleteUser,
  adjustWalletBalance,
};
