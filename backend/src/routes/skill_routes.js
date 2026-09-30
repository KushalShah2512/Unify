const express = require("express");

const {
  addSkill,
  getSkills,
  updateSkill,
  deleteSkill,
} = require("../controllers/skill_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();


// Add Skill
router.post(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  addSkill
);


// Get Skills
router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getSkills
);


// Update Skill
router.put(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  updateSkill
);


// Delete Skill
router.delete(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  deleteSkill
);

module.exports = router;