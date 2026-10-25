const express = require("express");

const {
  getOpportunities,
  applyToOpportunity,
  getMyApplications,
} = require("../controllers/opportunity_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

router.use(authenticateToken);
router.use(authorizeRoles("STUDENT"));

// Get Active Opportunities
router.get("/", getOpportunities);

// Get My Applications
router.get("/my-applications", getMyApplications);

// Apply to Opportunity
router.post("/:id/apply", applyToOpportunity);

module.exports = router;