  const prisma = require("../config/database");


// ====================
// Get Career Passport
// ====================

const getCareerPassport = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
      include: {
        skills: {
          orderBy: {
            createdAt: "desc",
          },
        },
        projects: {
          orderBy: {
            createdAt: "desc",
          },
        },
        certifications: {
          orderBy: {
            issueDate: "desc",
          },
        },
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    return res.status(200).json({
      message: "Career Passport retrieved successfully",
      status: "success",
      careerPassport: {
        personalInformation: {
          fullName: studentProfile.fullName,
          phone: studentProfile.phone,
          location: studentProfile.location,
          bio: studentProfile.bio,
        },

        careerInformation: {
          education: studentProfile.education,
          careerGoal: studentProfile.careerGoal,
          availability: studentProfile.availability,
        },

        skills: studentProfile.skills,

        projects: studentProfile.projects,

        certifications: studentProfile.certifications,
      },
    });
  } catch (error) {
    console.error("Get career passport error:", error);

    return res.status(500).json({
      message: "Failed to retrieve Career Passport",
      status: "error",
    });
  }
};


module.exports = {
  getCareerPassport,
};