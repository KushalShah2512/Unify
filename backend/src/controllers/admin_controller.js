const prisma = require("../config/database");

// Get high-level platform statistics
const getPlatformStats = async (req, res) => {
  try {
    const [
      totalUsers,
      totalStudents,
      totalEmployers,
      totalOpportunities,
      recentUsers,
      pendingEmployers,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { role: "STUDENT" } }),
      prisma.user.count({ where: { role: "EMPLOYER" } }),
      prisma.opportunity.count(),
      prisma.user.findMany({
        take: 5,
        orderBy: { createdAt: "desc" },
        select: {
          id: true,
          email: true,
          role: true,
          createdAt: true,
          studentProfile: { select: { fullName: true } },
          employerProfile: { select: { companyName: true, verificationStatus: true } },
        },
      }),
      prisma.employerProfile.count({
        where: { verificationStatus: "PENDING" },
      }),
    ]);

    return res.status(200).json({
      status: "success",
      stats: {
        totalUsers,
        totalStudents,
        totalEmployers,
        totalOpportunities,
        pendingEmployers,
      },
      recentUsers,
    });
  } catch (error) {
    console.error("Admin stats error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to fetch platform statistics",
    });
  }
};

// Get all users
const getAllUsers = async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        email: true,
        role: true,
        createdAt: true,
        studentProfile: {
          select: {
            fullName: true,
            phone: true,
            location: true,
            education: true,
          },
        },
        employerProfile: {
          select: {
            companyName: true,
            industry: true,
            verificationStatus: true,
            isVerified: true,
          },
        },
      },
    });

    return res.status(200).json({
      status: "success",
      users,
    });
  } catch (error) {
    console.error("Admin users error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to fetch users",
    });
  }
};

// Get employers list
const getEmployers = async (req, res) => {
  try {
    const employers = await prisma.employerProfile.findMany({
      include: {
        user: {
          select: {
            email: true,
            createdAt: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return res.status(200).json({
      status: "success",
      employers,
    });
  } catch (error) {
    console.error("Admin employers error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to fetch employers",
    });
  }
};

// Update employer verification
const updateEmployerVerification = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!["APPROVED", "REJECTED", "PENDING"].includes(status)) {
      return res.status(400).json({
        status: "error",
        message: "Invalid verification status",
      });
    }

    const updated = await prisma.employerProfile.update({
      where: { id: Number(id) },
      data: {
        verificationStatus: status,
        isVerified: status === "APPROVED",
      },
    });

    return res.status(200).json({
      status: "success",
      message: `Employer verification status updated to ${status}`,
      employer: updated,
    });
  } catch (error) {
    console.error("Update employer verification error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to update employer verification",
    });
  }
};

// Get all opportunities (including inactive ones)
const getAllOpportunities = async (req, res) => {
  try {
    const opportunities = await prisma.opportunity.findMany({
      orderBy: { createdAt: "desc" },
    });

    return res.status(200).json({
      status: "success",
      opportunities,
    });
  } catch (error) {
    console.error("Admin opportunities error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to fetch opportunities",
    });
  }
};

// Create opportunity
const createOpportunity = async (req, res) => {
  try {
    const {
      title,
      description,
      type,
      companyName,
      location,
      workMode,
      stipend,
      salary,
      applicationUrl,
      requiredSkills,
    } = req.body;

    if (!title || !type || !companyName) {
      return res.status(400).json({
        status: "error",
        message: "Title, type, and company name are required",
      });
    }

    const opportunity = await prisma.opportunity.create({
      data: {
        title,
        description,
        type,
        companyName,
        location,
        workMode: workMode || "Remote",
        stipend,
        salary,
        applicationUrl,
        requiredSkills: Array.isArray(requiredSkills) ? requiredSkills : [],
      },
    });

    return res.status(201).json({
      status: "success",
      message: "Opportunity created successfully",
      opportunity,
    });
  } catch (error) {
    console.error("Create opportunity error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to create opportunity",
    });
  }
};

// Delete opportunity
const deleteOpportunity = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.opportunity.delete({
      where: { id: Number(id) },
    });

    return res.status(200).json({
      status: "success",
      message: "Opportunity deleted successfully",
    });
  } catch (error) {
    console.error("Delete opportunity error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to delete opportunity",
    });
  }
};

// Get all student opportunity applications
const getAllApplications = async (req, res) => {
  try {
    const applications = await prisma.application.findMany({
      include: {
        student: {
          include: {
            user: { select: { email: true } },
            skills: true,
            certifications: true,
            educationRecords: true,
          },
        },
        opportunity: true,
      },
      orderBy: { appliedAt: "desc" },
    });

    return res.status(200).json({
      status: "success",
      applications,
    });
  } catch (error) {
    console.error("Admin applications error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to fetch applications",
    });
  }
};

// Update application status
const updateApplicationStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const allowed = ["APPLIED", "UNDER_REVIEW", "SHORTLISTED", "ACCEPTED", "REJECTED"];
    if (!allowed.includes(status)) {
      return res.status(400).json({
        status: "error",
        message: "Invalid status value",
      });
    }

    const updated = await prisma.application.update({
      where: { id: Number(id) },
      data: { status },
    });

    return res.status(200).json({
      status: "success",
      message: `Application marked as ${status}`,
      application: updated,
    });
  } catch (error) {
    console.error("Update application status error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to update application status",
    });
  }
};

module.exports = {
  getPlatformStats,
  getAllUsers,
  getEmployers,
  updateEmployerVerification,
  getAllOpportunities,
  createOpportunity,
  deleteOpportunity,
  getAllApplications,
  updateApplicationStatus,
};
