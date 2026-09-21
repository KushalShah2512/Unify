const express = require("express");

const {
  getCareerPassport,
} = require("../controllers/career_passport_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();


// Get Career Passport
router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getCareerPassport
);


module.exports = router;