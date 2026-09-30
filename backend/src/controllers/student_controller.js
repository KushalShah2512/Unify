const prisma = require("../config/database");

const createProfile = async (req, res) => {
  try {
    const {
      fullName,
      phone,
      location,
      bio,
      education,
      careerGoal,
      availability,
    } = req.body;

    if (!fullName) {
      return res.status(400).json({
        message: "Full name is required",
        status: "error",
      });
    }

    const existingProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (existingProfile) {
      return res.status(409).json({
        message: "Student profile already exists",
        status: "error",
      });
    }

    const profile = await prisma.studentProfile.create({
      data: {
        userId: req.user.userId,
        fullName,
        phone,
        location,
        bio,
        education,
        careerGoal,
        availability,
      },
    });

    return res.status(201).json({
      message: "Student profile created successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Create student profile error:", error);

    return res.status(500).json({
      message: "Failed to create student profile",
      status: "error",
    });
  }
};


const getProfile = async (req, res) => {
  try {
    const profile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },

      include: {
        user: {
          select: {
            email: true,
          },
        },
      },
    });

    if (!profile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    return res.status(200).json({
      message: "Student profile retrieved successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Get student profile error:", error);

    return res.status(500).json({
      message: "Failed to retrieve student profile",
      status: "error",
    });
  }
};


const updateProfile = async (req, res) => {
  try {
    const {
      fullName,
      phone,
      location,
      bio,
      education,
      careerGoal,
      availability,
    } = req.body;

    const existingProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!existingProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const profile = await prisma.studentProfile.update({
      where: {
        userId: req.user.userId,
      },
      data: {
        fullName,
        phone,
        location,
        bio,
        education,
        careerGoal,
        availability,
      },
    });

    return res.status(200).json({
      message: "Student profile updated successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Update student profile error:", error);

    return res.status(500).json({
      message: "Failed to update student profile",
      status: "error",
    });
  }
};


module.exports = {
  createProfile,
  getProfile,
  updateProfile,
};