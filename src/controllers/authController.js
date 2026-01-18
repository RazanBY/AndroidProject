const db = require("../config/database");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const register = async (req, res) => {
  try {
    const { name, email, password, phone, user_type } = req.body;

    const [existing] = await db.execute(
      "SELECT id FROM users WHERE email = ?",
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: "البريد الإلكتروني مستخدم بالفعل",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.execute(
      "INSERT INTO users (name, email, password, phone, user_type) VALUES (?, ?, ?, ?, ?)",
      [name, email, hashedPassword, phone, user_type || "customer"]
    );

    const token = jwt.sign(
      { userId: result.insertId, email: email },
      process.env.JWT_SECRET,
      { expiresIn: "24h" }
    );

    res.status(201).json({
      success: true,
      message: "تم التسجيل بنجاح",
      userId: result.insertId,
      token: token,
    });
  } catch (error) {
    console.error("Registration error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء التسجيل",
      error: error.message,
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Get user
    const [users] = await db.execute(
      "SELECT id, name, email, password, user_type, wallet_balance FROM users WHERE email = ?",
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
      });
    }

    const user = users[0];

    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({
        success: false,
        message: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
      });
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email, userType: user.user_type },
      process.env.JWT_SECRET,
      { expiresIn: "24h" }
    );

    delete user.password;

    res.json({
      success: true,
      message: "تم تسجيل الدخول بنجاح",
      token: token,
      user: user,
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ أثناء تسجيل الدخول",
      error: error.message,
    });
  }
};

const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const [users] = await db.execute(
      "SELECT id, name, email, phone, user_type, wallet_balance FROM users WHERE id = ?",
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: "المستخدم غير موجود",
      });
    }

    res.json({
      success: true,
      user: users[0],
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({
      success: false,
      message: "حدث خطأ في جلب بيانات المستخدم",
    });
  }
};

module.exports = {
  register,
  login,
  getUserProfile,
};
