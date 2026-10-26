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
    let profile = await prisma.studentProfile.findUnique({
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
      // Auto-create profile using user's email if not created yet
      const user = await prisma.user.findUnique({
        where: { id: req.user.userId },
      });

      if (!user) {
        return res.status(404).json({
          message: "User not found",
          status: "error",
        });
      }

      const defaultName = user.email.split("@")[0];
      const formattedName = defaultName.charAt(0).toUpperCase() + defaultName.slice(1);

      profile = await prisma.studentProfile.create({
        data: {
          userId: user.id,
          fullName: formattedName,
        },
        include: {
          user: {
            select: {
              email: true,
            },
          },
        },
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

    const nameToSave = fullName && fullName.trim() !== "" ? fullName.trim() : "Student";

    const profile = await prisma.studentProfile.upsert({
      where: {
        userId: req.user.userId,
      },
      create: {
        userId: req.user.userId,
        fullName: nameToSave,
        phone: phone || null,
        location: location || null,
        bio: bio || null,
        education: education || null,
        careerGoal: careerGoal || null,
        availability: availability || null,
      },
      update: {
        fullName: nameToSave,
        phone: phone || null,
        location: location || null,
        bio: bio || null,
        education: education || null,
        careerGoal: careerGoal || null,
        availability: availability || null,
      },
      include: {
        user: {
          select: {
            email: true,
          },
        },
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

// ==========================================
// Resume Document Upload & Verification
// ==========================================
const uploadResume = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        status: "error",
        message: "No resume file uploaded. Please upload a PDF, DOCX, or TXT document.",
      });
    }

    const host = req.get("host") || "localhost:5000";
    const protocol = req.protocol || "http";
    const resumeUrl = `${protocol}://${host}/uploads/resumes/${req.file.filename}`;

    const profile = await prisma.studentProfile.update({
      where: { userId: req.user.userId },
      data: {
        resumeUrl,
        resumeName: req.file.originalname,
        resumeSize: req.file.size,
        resumeUpdatedAt: new Date(),
        isResumeVerified: false,
      },
    });

    // Notify user of upload
    try {
      await prisma.notification.create({
        data: {
          userId: req.user.userId,
          title: "Resume Document Uploaded",
          message: `Your resume "${req.file.originalname}" has been uploaded and submitted for verification.`,
          type: "SYSTEM",
        },
      });
    } catch (_) {}

    return res.status(200).json({
      status: "success",
      message: "Resume uploaded successfully",
      resume: {
        resumeUrl: profile.resumeUrl,
        resumeName: profile.resumeName,
        resumeSize: profile.resumeSize,
        resumeUpdatedAt: profile.resumeUpdatedAt,
        isResumeVerified: profile.isResumeVerified,
      },
    });
  } catch (error) {
    console.error("Upload resume error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to upload resume file",
    });
  }
};

const getResume = async (req, res) => {
  try {
    const profile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
      select: {
        resumeUrl: true,
        resumeName: true,
        resumeSize: true,
        resumeUpdatedAt: true,
        isResumeVerified: true,
      },
    });

    return res.status(200).json({
      status: "success",
      resume: profile || null,
    });
  } catch (error) {
    console.error("Get resume error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to get resume information",
    });
  }
};

const deleteResume = async (req, res) => {
  try {
    await prisma.studentProfile.update({
      where: { userId: req.user.userId },
      data: {
        resumeUrl: null,
        resumeName: null,
        resumeSize: null,
        resumeUpdatedAt: null,
        isResumeVerified: false,
      },
    });

    return res.status(200).json({
      status: "success",
      message: "Resume removed successfully",
    });
  } catch (error) {
    console.error("Delete resume error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to remove resume",
    });
  }
};

module.exports = {
  createProfile,
  getProfile,
  updateProfile,
  uploadResume,
  getResume,
  deleteResume,
};