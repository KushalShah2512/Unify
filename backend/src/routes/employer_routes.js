const express = require("express");

const {
  createProfile,
  getProfile,
  updateProfile,
} = require("../controllers/employer_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();


// Create Employer Profile
router.post(
  "/profile",
  authenticateToken,
  authorizeRoles("EMPLOYER"),
  createProfile
);


// Get Employer Profile
router.get(
  "/profile",
  authenticateToken,
  authorizeRoles("EMPLOYER"),
  getProfile
);


// Update Employer Profile
router.put(
  "/profile",
  authenticateToken,
  authorizeRoles("EMPLOYER"),
  updateProfile
);


module.exports = router;