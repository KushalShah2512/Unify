const bcrypt = require("bcrypt");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");
const { OAuth2Client } = require("google-auth-library");
const prisma = require("../config/database");

const googleClient = new OAuth2Client();

const getResetMailer = () => {
  if (!process.env.SMTP_HOST) return null;
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: process.env.SMTP_SECURE === "true",
    auth: process.env.SMTP_USER
      ? { user: process.env.SMTP_USER, pass: process.env.SMTP_PASSWORD }
      : undefined,
  });
};

const normalizeEmail = (email) => email.trim().toLowerCase();
const isValidEmail = (email) => /^\S+@\S+\.\S+$/.test(email);
const hashResetCode = (code) =>
  crypto.createHash("sha256").update(code).digest("hex");

const register = async (req, res) => {
  try {
    const { password, role } = req.body;
    const email = typeof req.body.email === "string"
      ? normalizeEmail(req.body.email)
      : "";

    if (!email || !password || !role) {
      return res.status(400).json({
        message: "Email, password and role are required",
        status: "error",
      });
    }

    const allowedRoles = ["STUDENT", "EMPLOYER"];

    if (!allowedRoles.includes(role)) {
      return res.status(400).json({
        message: "Invalid role",
        status: "error",
      });
    }

    const existingUser = await prisma.user.findUnique({
      where: {
        email,
      },
    });

    if (existingUser) {
      return res.status(409).json({
        message: "User with this email already exists",
        status: "error",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        role,
      },
    });

    return res.status(201).json({
      message: "User registered successfully",
      status: "success",
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Registration error:", error);

    return res.status(500).json({
      message: "Something went wrong during registration",
      status: "error",
    });
  }
};


const login = async (req, res) => {
  try {
    const { password } = req.body;
    const email = typeof req.body.email === "string"
      ? normalizeEmail(req.body.email)
      : "";

    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
        status: "error",
      });
    }

    const user = await prisma.user.findUnique({
      where: {
        email,
      },
    });

    if (!user) {
      return res.status(401).json({
        message: "Invalid email or password",
        status: "error",
      });
    }

    if (!isValidEmail(email) || password.length < 8) {
      return res.status(400).json({
        message: "Use a valid email and a password of at least 8 characters",
        status: "error",
      });
    }

    if (!user.password) {
      return res.status(401).json({
        message: "This account uses Google Sign-In. Please continue with Google.",
        status: "error",
      });
    }

    const passwordMatch = await bcrypt.compare(
      password,
      user.password
    );

    if (!passwordMatch) {
      return res.status(401).json({
        message: "Invalid email or password",
        status: "error",
      });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    return res.status(200).json({
      message: "Login successful",
      status: "success",
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Login error:", error);

    return res.status(500).json({
      message: "Something went wrong during login",
      status: "error",
    });
  }
};

const googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        message: "Google ID token is required",
        status: "error",
      });
    }

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience:
        "729101956164-rm9npvconf2bulul56b0239v4jqgoq36.apps.googleusercontent.com",
    });

    const payload = ticket.getPayload();

    if (!payload || !payload.sub || !payload.email) {
      return res.status(401).json({
        message: "Invalid Google account",
        status: "error",
      });
    }

    const googleId = payload.sub;
    const email = normalizeEmail(payload.email);

    let user = await prisma.user.findUnique({
      where: {
        googleId,
      },
    });

    if (!user) {
      user = await prisma.user.findUnique({
        where: {
          email,
        },
      });

      if (user) {
        user = await prisma.user.update({
          where: {
            id: user.id,
          },
          data: {
            googleId,
          },
        });
      } else {
        user = await prisma.user.create({
          data: {
            email,
            googleId,
            role: "STUDENT",
          },
        });
      }
    }

    const googleFullName = payload.name || payload.given_name || email.split("@")[0];
    let studentProfile = null;
    if (user.role === "STUDENT") {
      studentProfile = await prisma.studentProfile.findUnique({ where: { userId: user.id } });
      if (!studentProfile) {
        studentProfile = await prisma.studentProfile.create({ data: { userId: user.id, fullName: googleFullName } });
      }
    }

    const token = jwt.sign(
      {
        userId: user.id,
        role: user.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      }
    );

    return res.status(200).json({
      message: "Google login successful",
      status: "success",
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Google login error:", error);

    return res.status(401).json({
      message: "Google authentication failed",
      status: "error",
    });
  }
};

const requestPasswordReset = async (req, res) => {
  try {
    const email = typeof req.body.email === "string"
      ? normalizeEmail(req.body.email)
      : "";

    if (!email) {
      return res.status(400).json({
        message: "Email is required",
        status: "error",
      });
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.password) {
      return res.status(200).json({
        message: "If an account exists for this email, a reset code has been sent.",
        status: "success",
      });
    }

    const code = crypto.randomInt(100000, 1000000).toString();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await prisma.user.update({
      where: { id: user.id },
      data: {
        passwordResetToken: hashResetCode(code),
        passwordResetExpires: expiresAt,
      },
    });

    console.log(`\n========================================`);
    console.log(`🔑 PASSWORD RESET CODE for ${user.email}: [ ${code} ]`);
    console.log(`========================================\n`);

    const resetMailer = getResetMailer();
    const mailFrom = process.env.MAIL_FROM;

    if (!resetMailer || !mailFrom) {
      if (process.env.NODE_ENV === "production") {
        return res.status(503).json({
          message: "Password reset email is not configured yet",
          status: "error",
        });
      }

      return res.status(200).json({
        message: "Password reset code sent. Check your email or console.",
        status: "success",
      });
    }

    try {
      await resetMailer.sendMail({
        from: mailFrom,
        to: user.email,
        subject: "Your Unify password reset code",
        text: `Your Unify password reset code is ${code}. It expires in 15 minutes.`,
      });
    } catch (mailError) {
      console.error("Failed to send reset email via SMTP:", mailError.message || mailError);
      if (process.env.NODE_ENV !== "production") {
        return res.status(200).json({
          message: "A reset code has been generated (check backend console).",
          status: "success",
        });
      }
      throw mailError;
    }

    return res.status(200).json({
      message: "If an account exists for this email, a reset code has been sent.",
      status: "success",
    });
  } catch (error) {
    console.error("Password reset request error:", error);
    return res.status(500).json({
      message: "Unable to send a password reset code. Please try again.",
      status: "error",
    });
  }
};

const resetPassword = async (req, res) => {
  try {
    const email = typeof req.body.email === "string"
      ? normalizeEmail(req.body.email)
      : "";
    const { code, password } = req.body;

    if (!email || typeof code !== "string" || typeof password !== "string") {
      return res.status(400).json({
        message: "Email, reset code and new password are required",
        status: "error",
      });
    }

    if (!/^\d{6}$/.test(code) || password.length < 8) {
      return res.status(400).json({
        message: "Use a valid six-digit code and a password of at least 8 characters",
        status: "error",
      });
    }

    const user = await prisma.user.findFirst({
      where: {
        email,
        passwordResetToken: hashResetCode(code),
        passwordResetExpires: { gt: new Date() },
      },
    });

    if (!user) {
      return res.status(400).json({
        message: "The reset code is invalid or has expired",
        status: "error",
      });
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        password: await bcrypt.hash(password, 10),
        passwordResetToken: null,
        passwordResetExpires: null,
      },
    });

    return res.status(200).json({
      message: "Password reset successfully. Please sign in.",
      status: "success",
    });
  } catch (error) {
    console.error("Password reset error:", error);
    return res.status(500).json({
      message: "Unable to reset password. Please try again.",
      status: "error",
    });
  }
};

module.exports = {
  register,
  login,
  googleLogin,
  requestPasswordReset,
  resetPassword,
};
