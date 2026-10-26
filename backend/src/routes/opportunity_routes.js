const express = require("express");

const {
  getOpportunities,
  applyToOpportunity,
  getMyApplications,
  toggleSaveOpportunity,
  getSavedOpportunities,
  reportOpportunity,
} = require("../controllers/opportunity_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

router.use(authenticateToken);
router.use(authorizeRoles("STUDENT"));

// Get Active Opportunities
router.get("/", getOpportunities);

// Saved / Bookmarked Opportunities
router.get("/saved", getSavedOpportunities);

// Get My Applications
router.get("/my-applications", getMyApplications);

// Apply to Opportunity
router.post("/:id/apply", applyToOpportunity);

// Toggle Save / Bookmark
router.post("/:id/save", toggleSaveOpportunity);

// Report Suspicious Listing
router.post("/:id/report", reportOpportunity);

module.exports = router;