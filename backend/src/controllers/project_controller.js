const prisma = require("../config/database");

// ====================
// Add Project
// ====================

const addProject = async (req, res) => {
  try {
    const {
      title,
      description,
      technologies,
      projectUrl,
    } = req.body;

    if (!title) {
      return res.status(400).json({
        message: "Project title is required",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const project = await prisma.project.create({
      data: {
        title,
        description,
        technologies,
        projectUrl,
        studentId: studentProfile.id,
      },
    });

    return res.status(201).json({
      message: "Project added successfully",
      status: "success",
      project,
    });
  } catch (error) {
    console.error("Add project error:", error);

    return res.status(500).json({
      message: "Failed to add project",
      status: "error",
    });
  }
};


// ====================
// Get Projects
// ====================

const getProjects = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const projects = await prisma.project.findMany({
      where: {
        studentId: studentProfile.id,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.status(200).json({
      message: "Projects retrieved successfully",
      status: "success",
      projects,
    });
  } catch (error) {
    console.error("Get projects error:", error);

    return res.status(500).json({
      message: "Failed to retrieve projects",
      status: "error",
    });
  }
};


// ====================
// Update Project
// ====================

const updateProject = async (req, res) => {
  try {
    const projectId = parseInt(req.params.id);

    const {
      title,
      description,
      technologies,
      projectUrl,
    } = req.body;

    if (isNaN(projectId)) {
      return res.status(400).json({
        message: "Invalid project ID",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const existingProject = await prisma.project.findFirst({
      where: {
        id: projectId,
        studentId: studentProfile.id,
      },
    });

    if (!existingProject) {
      return res.status(404).json({
        message: "Project not found",
        status: "error",
      });
    }

    const project = await prisma.project.update({
      where: {
        id: projectId,
      },
      data: {
        title,
        description,
        technologies,
        projectUrl,
      },
    });

    return res.status(200).json({
      message: "Project updated successfully",
      status: "success",
      project,
    });
  } catch (error) {
    console.error("Update project error:", error);

    return res.status(500).json({
      message: "Failed to update project",
      status: "error",
    });
  }
};


// ====================
// Delete Project
// ====================

const deleteProject = async (req, res) => {
  try {
    const projectId = parseInt(req.params.id);

    if (isNaN(projectId)) {
      return res.status(400).json({
        message: "Invalid project ID",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const existingProject = await prisma.project.findFirst({
      where: {
        id: projectId,
        studentId: studentProfile.id,
      },
    });

    if (!existingProject) {
      return res.status(404).json({
        message: "Project not found",
        status: "error",
      });
    }

    await prisma.project.delete({
      where: {
        id: projectId,
      },
    });

    return res.status(200).json({
      message: "Project deleted successfully",
      status: "success",
    });
  } catch (error) {
    console.error("Delete project error:", error);

    return res.status(500).json({
      message: "Failed to delete project",
      status: "error",
    });
  }
};


module.exports = {
  addProject,
  getProjects,
  updateProject,
  deleteProject,
};