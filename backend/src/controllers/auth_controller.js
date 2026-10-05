const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const prisma = require("../config/database");

const googleClient = new OAuth2Client();

const register = async (req, res) => {
  try {
    const { email, password, role } = req.body;

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
    const { email, password } = req.body;

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
    const email = payload.email;

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

module.exports = {
  register,
  login,
  googleLogin,
};