const express = require("express");
const {
  getPlatformStats,
  getAllUsers,
  getEmployers,
  updateEmployerVerification,
  getAllOpportunities,
  createOpportunity,
  updateOpportunity,
  deleteOpportunity,
  getAllApplications,
  updateApplicationStatus,
  verifyStudentResume,
  getAllReports,
  resolveReport,
} = require("../controllers/admin_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

// Apply auth + ADMIN role middleware to all admin routes
router.use(authenticateToken);
router.use(authorizeRoles("ADMIN"));

router.get("/stats", getPlatformStats);
router.get("/users", getAllUsers);
router.get("/employers", getEmployers);
router.put("/employers/:id/verify", updateEmployerVerification);
router.get("/opportunities", getAllOpportunities);
router.post("/opportunities", createOpportunity);
router.put("/opportunities/:id", updateOpportunity);
router.delete("/opportunities/:id", deleteOpportunity);

// Applications management
router.get("/applications", getAllApplications);
router.put("/applications/:id/status", updateApplicationStatus);

// Student resume verification
router.put("/students/:studentId/verify-resume", verifyStudentResume);

// Opportunity reports moderation
router.get("/reports", getAllReports);
router.put("/reports/:id/resolve", resolveReport);

module.exports = router;
