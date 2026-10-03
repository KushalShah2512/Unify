const express = require("express");

const {
  analyzeOpportunityReadiness,
} = require("../controllers/ai_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

// Analyze Opportunity Readiness
router.post(
  "/opportunity-readiness",
  authenticateToken,
  authorizeRoles("STUDENT"),
  analyzeOpportunityReadiness
);

module.exports = router;