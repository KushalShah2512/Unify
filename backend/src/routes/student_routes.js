const express = require("express");
const multer = require("multer");
const path = require("path");

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

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const extension = path.extname(file.originalname).toLowerCase();
    const allowedExtensions = new Set([".pdf", ".docx", ".txt"]);

    if (!allowedExtensions.has(extension)) {
      return cb(new Error("Only PDF, DOCX, and TXT resumes are allowed."));
    }

    return cb(null, true);
  },
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
