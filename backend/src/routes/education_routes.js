const express = require("express");

const {
  addEducation,
  getEducation,
  updateEducation,
  deleteEducation,
} = require("../controllers/education_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

router.post(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  addEducation
);

router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getEducation
);

router.put(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  updateEducation
);

router.delete(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  deleteEducation
);

module.exports = router;