const prisma = require("../config/database");

// ====================
// Add Skill
// ====================

const addSkill = async (req, res) => {
  try {
    const { name, level } = req.body;

    if (!name) {
      return res.status(400).json({
        message: "Skill name is required",
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

    const skill = await prisma.skill.create({
      data: {
        name,
        level,
        studentId: studentProfile.id,
      },
    });

    return res.status(201).json({
      message: "Skill added successfully",
      status: "success",
      skill,
    });
  } catch (error) {
    console.error("Add skill error:", error);

    return res.status(500).json({
      message: "Failed to add skill",
      status: "error",
    });
  }
};


// ====================
// Get Skills
// ====================

const getSkills = async (req, res) => {
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

    const skills = await prisma.skill.findMany({
      where: {
        studentId: studentProfile.id,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.status(200).json({
      message: "Skills retrieved successfully",
      status: "success",
      skills,
    });
  } catch (error) {
    console.error("Get skills error:", error);

    return res.status(500).json({
      message: "Failed to retrieve skills",
      status: "error",
    });
  }
};


// ====================
// Update Skill
// ====================

const updateSkill = async (req, res) => {
  try {
    const skillId = parseInt(req.params.id);
    const { name, level } = req.body;

    if (isNaN(skillId)) {
      return res.status(400).json({
        message: "Invalid skill ID",
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

    const existingSkill = await prisma.skill.findFirst({
      where: {
        id: skillId,
        studentId: studentProfile.id,
      },
    });

    if (!existingSkill) {
      return res.status(404).json({
        message: "Skill not found",
        status: "error",
      });
    }

    const skill = await prisma.skill.update({
      where: {
        id: skillId,
      },
      data: {
        name,
        level,
      },
    });

    return res.status(200).json({
      message: "Skill updated successfully",
      status: "success",
      skill,
    });
  } catch (error) {
    console.error("Update skill error:", error);

    return res.status(500).json({
      message: "Failed to update skill",
      status: "error",
    });
  }
};


// ====================
// Delete Skill
// ====================

const deleteSkill = async (req, res) => {
  try {
    const skillId = parseInt(req.params.id);

    if (isNaN(skillId)) {
      return res.status(400).json({
        message: "Invalid skill ID",
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

    const existingSkill = await prisma.skill.findFirst({
      where: {
        id: skillId,
        studentId: studentProfile.id,
      },
    });

    if (!existingSkill) {
      return res.status(404).json({
        message: "Skill not found",
        status: "error",
      });
    }

    await prisma.skill.delete({
      where: {
        id: skillId,
      },
    });

    return res.status(200).json({
      message: "Skill deleted successfully",
      status: "success",
    });
  } catch (error) {
    console.error("Delete skill error:", error);

    return res.status(500).json({
      message: "Failed to delete skill",
      status: "error",
    });
  }
};


module.exports = {
  addSkill,
  getSkills,
  updateSkill,
  deleteSkill,
};