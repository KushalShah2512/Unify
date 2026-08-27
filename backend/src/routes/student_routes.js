const express = require("express");

const {
  createProfile,
  getProfile,
  updateProfile,
} = require("../controllers/student_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

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

module.exports = router;