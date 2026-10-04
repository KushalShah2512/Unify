const express = require("express");

const {
  getOpportunities,
} = require("../controllers/opportunity_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

// Get Active Opportunities
router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getOpportunities
);

module.exports = router;