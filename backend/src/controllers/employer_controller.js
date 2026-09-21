const prisma = require("../config/database");

// ====================
// Create Employer Profile
// ====================

const createProfile = async (req, res) => {
  try {
    const {
      companyName,
      description,
      industry,
      website,
      location,
    } = req.body;

    if (!companyName) {
      return res.status(400).json({
        message: "Company name is required",
        status: "error",
      });
    }

    const existingProfile = await prisma.employerProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (existingProfile) {
      return res.status(409).json({
        message: "Employer profile already exists",
        status: "error",
      });
    }

    const profile = await prisma.employerProfile.create({
      data: {
        userId: req.user.userId,
        companyName,
        description,
        industry,
        website,
        location,
      },
    });

    return res.status(201).json({
      message: "Employer profile created successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Create employer profile error:", error);

    return res.status(500).json({
      message: "Failed to create employer profile",
      status: "error",
    });
  }
};


// ====================
// Get Employer Profile
// ====================

const getProfile = async (req, res) => {
  try {
    const profile = await prisma.employerProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!profile) {
      return res.status(404).json({
        message: "Employer profile not found",
        status: "error",
      });
    }

    return res.status(200).json({
      message: "Employer profile retrieved successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Get employer profile error:", error);

    return res.status(500).json({
      message: "Failed to retrieve employer profile",
      status: "error",
    });
  }
};


// ====================
// Update Employer Profile
// ====================

const updateProfile = async (req, res) => {
  try {
    const {
      companyName,
      description,
      industry,
      website,
      location,
    } = req.body;

    const existingProfile = await prisma.employerProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!existingProfile) {
      return res.status(404).json({
        message: "Employer profile not found",
        status: "error",
      });
    }

    const profile = await prisma.employerProfile.update({
      where: {
        userId: req.user.userId,
      },
      data: {
        companyName,
        description,
        industry,
        website,
        location,
      },
    });

    return res.status(200).json({
      message: "Employer profile updated successfully",
      status: "success",
      profile,
    });
  } catch (error) {
    console.error("Update employer profile error:", error);

    return res.status(500).json({
      message: "Failed to update employer profile",
      status: "error",
    });
  }
};


module.exports = {
  createProfile,
  getProfile,
  updateProfile,
};