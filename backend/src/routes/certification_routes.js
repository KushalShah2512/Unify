const express = require("express");

const {
  addCertification,
  getCertifications,
  updateCertification,
  deleteCertification,
} = require("../controllers/certification_controller");

const {
  authenticateToken,
} = require("../middleware/auth_middleware");

const {
  authorizeRoles,
} = require("../middleware/role_middleware");

const router = express.Router();


// Add Certification
router.post(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  addCertification
);


// Get Certifications
router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getCertifications
);


// Update Certification
router.put(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  updateCertification
);


// Delete Certification
router.delete(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  deleteCertification
);

module.exports = router;