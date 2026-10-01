const prisma = require("../config/database");

const addEducation = async (req, res) => {
  try {
    const {
      institution,
      degree,
      fieldOfStudy,
      startDate,
      endDate,
      description,
    } = req.body;

    if (!institution || !degree) {
      return res.status(400).json({
        message: "Institution and degree are required",
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

    const education = await prisma.education.create({
      data: {
        institution,
        degree,
        fieldOfStudy,
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
        description,
        studentId: studentProfile.id,
      },
    });

    res.status(201).json({
      message: "Education added successfully",
      status: "success",
      education,
    });
  } catch (error) {
    console.error("Add education error:", error);

    res.status(500).json({
      message: "Failed to add education",
      status: "error",
    });
  }
};

const getEducation = async (req, res) => {
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

    const education = await prisma.education.findMany({
      where: {
        studentId: studentProfile.id,
      },
      orderBy: {
        startDate: "desc",
      },
    });

    res.json({
      message: "Education fetched successfully",
      status: "success",
      education,
    });
  } catch (error) {
    console.error("Get education error:", error);

    res.status(500).json({
      message: "Failed to fetch education",
      status: "error",
    });
  }
};

const updateEducation = async (req, res) => {
  try {
    const educationId = Number(req.params.id);

    const {
      institution,
      degree,
      fieldOfStudy,
      startDate,
      endDate,
      description,
    } = req.body;

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

    const existingEducation = await prisma.education.findFirst({
      where: {
        id: educationId,
        studentId: studentProfile.id,
      },
    });

    if (!existingEducation) {
      return res.status(404).json({
        message: "Education record not found",
        status: "error",
      });
    }

    const education = await prisma.education.update({
      where: {
        id: educationId,
      },
      data: {
        institution,
        degree,
        fieldOfStudy,
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
        description,
      },
    });

    res.json({
      message: "Education updated successfully",
      status: "success",
      education,
    });
  } catch (error) {
    console.error("Update education error:", error);

    res.status(500).json({
      message: "Failed to update education",
      status: "error",
    });
  }
};

const deleteEducation = async (req, res) => {
  try {
    const educationId = Number(req.params.id);

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

    const existingEducation = await prisma.education.findFirst({
      where: {
        id: educationId,
        studentId: studentProfile.id,
      },
    });

    if (!existingEducation) {
      return res.status(404).json({
        message: "Education record not found",
        status: "error",
      });
    }

    await prisma.education.delete({
      where: {
        id: educationId,
      },
    });

    res.json({
      message: "Education deleted successfully",
      status: "success",
    });
  } catch (error) {
    console.error("Delete education error:", error);

    res.status(500).json({
      message: "Failed to delete education",
      status: "error",
    });
  }
};

module.exports = {
  addEducation,
  getEducation,
  updateEducation,
  deleteEducation,
};