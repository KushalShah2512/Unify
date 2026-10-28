const express = require("express");
const multer = require("multer");
const path = require("path");
const { resumeUploadDir } = require("../config/uploads");

const {
  createProfile,
  getProfile,
  updateProfile,
  uploadResume,
  getResume,
  deleteResume,
} = require("../controllers/student_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

// Multer storage for uploaded resume documents
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, resumeUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `resume-${req.user.userId}-${Date.now()}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
});

router.post(
  "/profile",
  authenticateToken,
  authorizeRoles("STUDENT"),
  createProfile
);

router.get(
  "/profile",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getProfile
);

router.put(
  "/profile",
  authenticateToken,
  authorizeRoles("STUDENT"),
  updateProfile
);

// Resume upload, retrieval & deletion
router.post(
  "/resume",
  authenticateToken,
  authorizeRoles("STUDENT"),
  upload.single("resume"),
  uploadResume
);

router.get(
  "/resume",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getResume
);

router.delete(
  "/resume",
  authenticateToken,
  authorizeRoles("STUDENT"),
  deleteResume
);

module.exports = router;
