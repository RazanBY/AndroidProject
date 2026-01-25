const db = require("../config/database");

// 1. جلب رصيد المحفظة
const getWalletBalance = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [users] = await db.execute(
      "SELECT wallet_balance FROM users WHERE id = ?",
      [userId],
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    res.json({
      success: true,
      balance: users[0].wallet_balance,
    });
  } catch (error) {
    console.error("Get wallet balance error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب رصيد المحفظة",
    });
  }
};

// 2. شحن المحفظة
const depositToWallet = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount } = req.body;

    // التحقق من البيانات
    if (!amount || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: "المبلغ غير صالح",
      });
    }

    // زيادة رصيد المستخدم
    await db.execute(
      "UPDATE users SET wallet_balance = wallet_balance + ? WHERE id = ?",
      [amount, userId],
    );

    // تسجيل العملية في جدول transactions
    const [result] = await db.execute(
      "INSERT INTO transactions (user_id, amount, type) VALUES (?, ?, ?)",
      [userId, amount, "deposit"],
    );

    // جلب الرصيد الجديد
    const [users] = await db.execute(
      "SELECT wallet_balance FROM users WHERE id = ?",
      [userId],
    );

    res.json({
      success: true,
      message: "تم شحن المحفظة بنجاح",
      transactionId: result.insertId,
      newBalance: users[0].wallet_balance,
    });
  } catch (error) {
    console.error("Deposit error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء شحن المحفظة",
    });
  }
};

// 3. جلب سجل المعاملات
const getTransactions = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [transactions] = await db.execute(
      `SELECT 
        t.id,
        t.amount,
        t.type,
        t.timestamp,
        t.booking_id,
        b.status as booking_status,
        s.name as service_name
      FROM transactions t
      LEFT JOIN bookings b ON t.booking_id = b.id
      LEFT JOIN services s ON b.service_id = s.id
      WHERE t.user_id = ?
      ORDER BY t.timestamp DESC`,
      [userId],
    );

    // حساب الإجماليات
    let totalDeposits = 0;
    let totalPayments = 0;

    transactions.forEach((transaction) => {
      if (transaction.type === "deposit") {
        totalDeposits += parseFloat(transaction.amount);
      } else if (transaction.type === "payment") {
        totalPayments += parseFloat(transaction.amount);
      }
    });

    res.json({
      success: true,
      transactions: transactions,
      summary: {
        totalDeposits: totalDeposits,
        totalPayments: totalPayments,
        netBalance: totalDeposits - totalPayments,
        count: transactions.length,
      },
    });
  } catch (error) {
    console.error("Get transactions error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب سجل المعاملات",
    });
  }
};

// 4. الدفع من المحفظة
const payFromWallet = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { booking_id } = req.body;

    if (!booking_id) {
      return res.status(400).json({
        success: false,
        message: "رقم الحجز مطلوب",
      });
    }

    // جلب بيانات الحجز
    const [bookings] = await db.execute(
      `SELECT 
        id,
        total_price,
        payment_status,
        user_id
      FROM bookings 
      WHERE id = ?`,
      [booking_id],
    );

    if (bookings.length === 0) {
      return res.status(404).json({
        success: false,
        message: "الحجز غير موجود",
      });
    }

    const booking = bookings[0];

    // التحقق من أن الحجز يخص المستخدم
    if (booking.user_id !== userId) {
      return res.status(403).json({
        success: false,
        message: "هذا الحجز لا يخصك",
      });
    }

    // التحقق من حالة الدفع
    if (booking.payment_status === "paid") {
      return res.status(400).json({
        success: false,
        message: "تم دفع هذا الحجز مسبقاً",
      });
    }

    // التحقق من رصيد المحفظة
    const [users] = await db.execute(
      "SELECT wallet_balance FROM users WHERE id = ?",
      [userId],
    );

    const currentBalance = users[0].wallet_balance;
    const amount = booking.total_price;

    if (currentBalance < amount) {
      return res.status(400).json({
        success: false,
        message: "رصيد المحفظة غير كافي",
        required: amount,
        available: currentBalance,
        missing: amount - currentBalance,
      });
    }

    // بدء transaction
    const connection = await db.getConnection();

    try {
      await connection.beginTransaction();

      // 1. خصم المبلغ من المحفظة
      await connection.execute(
        "UPDATE users SET wallet_balance = wallet_balance - ? WHERE id = ?",
        [amount, userId],
      );

      // 2. تحديث حالة الدفع للحجز
      await connection.execute(
        'UPDATE bookings SET payment_status = "paid", payment_method = "wallet" WHERE id = ?',
        [booking_id],
      );

      // 3. تسجيل العملية في transactions
      await connection.execute(
        "INSERT INTO transactions (user_id, amount, type, booking_id) VALUES (?, ?, ?, ?)",
        [userId, amount, "payment", booking_id],
      );

      await connection.commit();

      // جلب الرصيد الجديد
      const [updatedUser] = await db.execute(
        "SELECT wallet_balance FROM users WHERE id = ?",
        [userId],
      );

      res.json({
        success: true,
        message: "تم الدفع بنجاح من المحفظة",
        bookingId: booking_id,
        amount: amount,
        previousBalance: currentBalance,
        newBalance: updatedUser[0].wallet_balance,
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error("Payment error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء عملية الدفع",
    });
  }
};

// 5. جفل معاملة محددة
const getTransactionById = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const [transactions] = await db.execute(
      `SELECT 
        t.*,
        b.status as booking_status,
        s.name as service_name,
        s.price as service_price,
        u.name as user_name
      FROM transactions t
      LEFT JOIN bookings b ON t.booking_id = b.id
      LEFT JOIN services s ON b.service_id = s.id
      LEFT JOIN users u ON t.user_id = u.id
      WHERE t.id = ? AND t.user_id = ?`,
      [id, userId],
    );

    if (transactions.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المعاملة غير موجودة أو لا تخصك",
      });
    }

    res.json({
      success: true,
      transaction: transactions[0],
    });
  } catch (error) {
    console.error("Get transaction by ID error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات المعاملة",
    });
  }
};

// تصدير الدوال
module.exports = {
  getWalletBalance,
  depositToWallet,
  getTransactions,
  payFromWallet,
  getTransactionById,
};
