const express = require("express");
const cors = require("cors");
require("dotenv").config();

const prisma = require("./config/database");
const authRoutes = require("./routes/auth_routes");
const { authenticateToken } = require("./middleware/auth_middleware");
const { authorizeRoles } = require("./middleware/role_middleware");

const studentRoutes = require("./routes/student_routes");

const skillRoutes = require("./routes/skill_routes");

const projectRoutes = require("./routes/project_routes");

const certificationRoutes = require("./routes/certification_routes");

const careerPassportRoutes = require("./routes/career_passport_routes");

const employerRoutes = require("./routes/employer_routes");

const educationRoutes = require("./routes/education_routes");

const opportunityRoutes = require("./routes/opportunity_routes");

const { uploadRoot } = require("./config/uploads");
const aiRoutes = require("./routes/ai_routes");
const adminRoutes = require("./routes/admin_routes");
const notificationRoutes = require("./routes/notification_routes");
const app = express();

// Managed hosts sit behind a reverse proxy. This retains the original HTTPS
// protocol when generating public file URLs.
app.set("trust proxy", 1);

const allowedOrigins = (process.env.CORS_ORIGINS || "http://localhost:5173,http://localhost:3000")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(cors({
  origin(origin, callback) {
    // Requests without an Origin header include native mobile clients and health checks.
    if (!origin || allowedOrigins.includes(origin)) return callback(null, true);
    return callback(new Error("Origin not allowed by CORS"));
  },
}));
app.use(express.json());

// Serve uploaded documents statically
app.use("/uploads", express.static(uploadRoot));

app.use("/api/auth", authRoutes);

app.use("/api/students", studentRoutes);
app.use("/api/students/skills", skillRoutes);
app.use("/api/students/projects", projectRoutes);
app.use("/api/students/certifications", certificationRoutes);
app.use("/api/students/education", educationRoutes);
app.use("/api/students/career-passport", careerPassportRoutes);

app.use("/api/ai", aiRoutes);
app.use("/api/opportunities", opportunityRoutes);
app.use("/api/employers", employerRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/notifications", notificationRoutes);
// ====================
// Basic Routes
// ====================

app.get("/", (req, res) => {
  res.json({
    message: "Unify Backend API is running",
    status: "success",
  });
});


app.get("/api/health", (req, res) => {
  res.json({
    message: "Unify API is healthy",
    status: "success",
  });
});


// ====================
// Database Test
// ====================

app.get("/api/db-test", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;

    res.json({
      message: "Database connection successful",
      database: "PostgreSQL",
      status: "success",
    });
  } catch (error) {
    console.error("Database connection error:", error);

    res.status(500).json({
      message: "Database connection failed",
      status: "error",
    });
  }
});


// ====================
// Authentication Routes
// ====================

// app.use("/api/auth", authRoutes);


// ====================
// Protected Route
// ====================

// app.get("/api/protected", authenticateToken, (req, res) => {
//   res.json({
//     message: "You accessed a protected route",
//     status: "success",
//     user: req.user,
//   });
// });

// app.get(
//   "/api/student-only",
//   authenticateToken,
//   authorizeRoles("STUDENT"),
//   (req, res) => {
//     res.json({
//       message: "Student-only resource accessed successfully",
//       status: "success",
//       user: req.user,
//     });
//   }
// );

// app.get(
//   "/api/employer-only",
//   authenticateToken,
//   authorizeRoles("EMPLOYER"),
//   (req, res) => {
//     res.json({
//       message: "Employer-only resource accessed successfully",
//       status: "success",
//       user: req.user,
//     });
//   }
// );

// app.get(
//   "/api/admin-only",
//   authenticateToken,
//   authorizeRoles("ADMIN"),
//   (req, res) => {
//     res.json({
//       message: "Admin-only resource accessed successfully",
//       status: "success",
//       user: req.user,
//     });
//   }
// );

// ====================
// Start Server
// ====================

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Unify backend running on http://localhost:${PORT}`);
  console.log(`Unify backend accessible on network at http://10.23.46.7:${PORT}`);
});
