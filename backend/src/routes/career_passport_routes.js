const express = require("express");

const {
  getCareerPassport,
  exportCareerPassport,
} = require("../controllers/career_passport_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

router.use(authenticateToken);
router.use(authorizeRoles("STUDENT"));

// Get Career Passport
router.get("/", getCareerPassport);

// Export Career Passport
router.get("/export", exportCareerPassport);

module.exports = router;