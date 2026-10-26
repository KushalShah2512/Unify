const prisma = require("../config/database");

// ====================
// Get Active Opportunities
// ====================
const getOpportunities = async (req, res) => {
  try {
    const opportunities = await prisma.opportunity.findMany({
      where: {
        isActive: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return res.status(200).json({
      message: "Opportunities retrieved successfully",
      status: "success",
      opportunities,
    });
  } catch (error) {
    console.error("Get opportunities error:", error);
    return res.status(500).json({
      message: "Failed to retrieve opportunities",
      status: "error",
    });
  }
};

// ====================
// Apply to Opportunity
// ====================
const applyToOpportunity = async (req, res) => {
  try {
    const opportunityId = Number(req.params.id);
    const { coverLetter } = req.body;

    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
    });

    if (!studentProfile) {
      return res.status(404).json({
        status: "error",
        message: "Please complete your student profile before applying",
      });
    }

    const opportunity = await prisma.opportunity.findUnique({
      where: { id: opportunityId },
    });

    if (!opportunity || !opportunity.isActive) {
      return res.status(404).json({
        status: "error",
        message: "Opportunity not found or no longer active",
      });
    }

    // Check if already applied
    const existing = await prisma.application.findUnique({
      where: {
        studentId_opportunityId: {
          studentId: studentProfile.id,
          opportunityId,
        },
      },
    });

    if (existing) {
      return res.status(409).json({
        status: "error",
        message: "You have already applied to this opportunity",
      });
    }

    const application = await prisma.application.create({
      data: {
        studentId: studentProfile.id,
        opportunityId,
        coverLetter: coverLetter || null,
        status: "APPLIED",
      },
    });

    return res.status(201).json({
      status: "success",
      message: "Application submitted successfully! Your Career Passport has been shared.",
      application,
    });
  } catch (error) {
    console.error("Apply opportunity error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to submit application",
    });
  }
};

// ====================
// Get Student's Applied Opportunities
// ====================
const getMyApplications = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
    });

    if (!studentProfile) {
      return res.status(404).json({
        status: "error",
        message: "Student profile not found",
      });
    }

    const applications = await prisma.application.findMany({
      where: { studentId: studentProfile.id },
      include: {
        opportunity: true,
      },
      orderBy: { appliedAt: "desc" },
    });

    return res.status(200).json({
      status: "success",
      applications,
    });
  } catch (error) {
    console.error("Get my applications error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to retrieve applications",
    });
  }
};

// ==========================================
// Toggle Save / Bookmark Opportunity
// ==========================================
const toggleSaveOpportunity = async (req, res) => {
  try {
    const opportunityId = Number(req.params.id);

    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
    });

    if (!studentProfile) {
      return res.status(404).json({
        status: "error",
        message: "Student profile not found",
      });
    }

    const existing = await prisma.savedOpportunity.findUnique({
      where: {
        studentId_opportunityId: {
          studentId: studentProfile.id,
          opportunityId,
        },
      },
    });

    if (existing) {
      await prisma.savedOpportunity.delete({
        where: { id: existing.id },
      });

      return res.status(200).json({
        status: "success",
        isSaved: false,
        message: "Opportunity removed from saved bookmarks",
      });
    }

    await prisma.savedOpportunity.create({
      data: {
        studentId: studentProfile.id,
        opportunityId,
      },
    });

    return res.status(201).json({
      status: "success",
      isSaved: true,
      message: "Opportunity saved to bookmarks",
    });
  } catch (error) {
    console.error("Toggle save opportunity error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to update saved status",
    });
  }
};

// ==========================================
// Get All Saved / Bookmarked Opportunities
// ==========================================
const getSavedOpportunities = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
    });

    if (!studentProfile) {
      return res.status(404).json({
        status: "error",
        message: "Student profile not found",
      });
    }

    const saved = await prisma.savedOpportunity.findMany({
      where: { studentId: studentProfile.id },
      include: {
        opportunity: true,
      },
      orderBy: { savedAt: "desc" },
    });

    return res.status(200).json({
      status: "success",
      savedOpportunities: saved.map((s) => ({
        ...s.opportunity,
        savedAt: s.savedAt,
      })),
    });
  } catch (error) {
    console.error("Get saved opportunities error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to retrieve saved opportunities",
    });
  }
};

// ==========================================
// Report Suspicious / Fraudulent Opportunity
// ==========================================
const reportOpportunity = async (req, res) => {
  try {
    const opportunityId = Number(req.params.id);
    const { reason, details } = req.body;

    if (!reason || reason.trim() === "") {
      return res.status(400).json({
        status: "error",
        message: "Please specify a reason for reporting this listing",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
    });

    if (!studentProfile) {
      return res.status(404).json({
        status: "error",
        message: "Student profile not found",
      });
    }

    const opportunity = await prisma.opportunity.findUnique({
      where: { id: opportunityId },
    });

    if (!opportunity) {
      return res.status(404).json({
        status: "error",
        message: "Opportunity not found",
      });
    }

    const report = await prisma.opportunityReport.create({
      data: {
        opportunityId,
        studentId: studentProfile.id,
        reason: reason.trim(),
        details: details ? details.trim() : null,
      },
    });

    // Notify student that report is being investigated
    try {
      await prisma.notification.create({
        data: {
          userId: req.user.userId,
          title: "Safety Report Logged",
          message: `Your report on "${opportunity.title}" at ${opportunity.companyName} has been received. Our moderation team is investigating.`,
          type: "SYSTEM",
        },
      });
    } catch (_) {}

    return res.status(201).json({
      status: "success",
      message: "Thank you for helping keep Unify safe. The listing has been flagged for admin review.",
      report,
    });
  } catch (error) {
    console.error("Report opportunity error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to submit opportunity report",
    });
  }
};

module.exports = {
  getOpportunities,
  applyToOpportunity,
  getMyApplications,
  toggleSaveOpportunity,
  getSavedOpportunities,
  reportOpportunity,
};