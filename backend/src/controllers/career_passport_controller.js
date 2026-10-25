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
          orderBy: { createdAt: "desc" },
        },
        projects: {
          orderBy: { createdAt: "desc" },
        },
        certifications: {
          orderBy: { issueDate: "desc" },
        },
        educationRecords: {
          orderBy: { startDate: "desc" },
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
        educationRecords: studentProfile.educationRecords,
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

// ====================
// Export Career Passport Summary (Printable/Resume format)
// ====================
const exportCareerPassport = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
      include: {
        user: { select: { email: true } },
        skills: true,
        projects: true,
        certifications: true,
        educationRecords: true,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const passportDocument = {
      title: `${studentProfile.fullName} - Unify Verified Career Passport`,
      generatedAt: new Date().toISOString(),
      student: {
        name: studentProfile.fullName,
        email: studentProfile.user.email,
        phone: studentProfile.phone || "Not provided",
        location: studentProfile.location || "Not specified",
        careerGoal: studentProfile.careerGoal || "Professional",
        bio: studentProfile.bio || "",
      },
      skills: studentProfile.skills.map((s) => ({ name: s.name, level: s.level || "Intermediate" })),
      projects: studentProfile.projects.map((p) => ({
        title: p.title,
        description: p.description,
        technologies: p.technologies,
        url: p.projectUrl,
      })),
      certifications: studentProfile.certifications.map((c) => ({
        name: c.name,
        issuer: c.issuingOrg,
        date: c.issueDate,
        credentialUrl: c.credentialUrl,
      })),
      education: studentProfile.educationRecords.map((e) => ({
        institution: e.institution,
        degree: e.degree,
        field: e.fieldOfStudy,
        start: e.startDate,
        end: e.endDate,
        details: e.description,
      })),
      verificationSeal: {
        verifiedBy: "Unify Platform Career Passport Authority",
        timestamp: new Date().toISOString(),
        status: "AUTHENTIC",
      },
    };

    return res.status(200).json({
      status: "success",
      passportDocument,
    });
  } catch (error) {
    console.error("Export career passport error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to export Career Passport",
    });
  }
};

module.exports = {
  getCareerPassport,
  exportCareerPassport,
};