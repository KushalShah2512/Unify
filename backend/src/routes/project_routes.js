const express = require("express");

const {
  addProject,
  getProjects,
  updateProject,
  deleteProject,
} = require("../controllers/project_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();


// Add Project
router.post(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  addProject
);


// Get Projects
router.get(
  "/",
  authenticateToken,
  authorizeRoles("STUDENT"),
  getProjects
);


// Update Project
router.put(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  updateProject
);


// Delete Project
router.delete(
  "/:id",
  authenticateToken,
  authorizeRoles("STUDENT"),
  deleteProject
);


module.exports = router;