const prisma = require("../config/database");

// ====================
// AI Opportunity Readiness & Skill Gap Analysis
// ====================

const analyzeOpportunityReadiness = async (req, res) => {
  try {
    const { opportunity } = req.body;

    // Validate opportunity data
    if (!opportunity) {
      return res.status(400).json({
        message: "Opportunity data is required",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
      include: {
        skills: true,
        projects: true,
        certifications: true,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    // Student skills
    const studentSkills = studentProfile.skills.map((skill) =>
      skill.name.toLowerCase().trim()
    );

    // Opportunity required skills
    const requiredSkills = Array.isArray(opportunity.requiredSkills)
      ? opportunity.requiredSkills
      : [];

    const normalizedRequiredSkills = requiredSkills.map((skill) =>
      skill.toLowerCase().trim()
    );

    // Find matching skills
    const matchingSkills = normalizedRequiredSkills.filter((skill) =>
      studentSkills.includes(skill)
    );

    // Find missing skills
    const missingSkills = normalizedRequiredSkills.filter(
      (skill) => !studentSkills.includes(skill)
    );

    // Calculate basic readiness percentage
    const readinessPercentage =
      normalizedRequiredSkills.length > 0
        ? Math.round(
            (matchingSkills.length /
              normalizedRequiredSkills.length) *
              100
          )
        : 0;

    return res.status(200).json({
      message: "Opportunity readiness analysis completed",
      status: "success",

      analysis: {
        student: {
          name: studentProfile.fullName,
          careerGoal: studentProfile.careerGoal,
        },

        opportunity: {
          title: opportunity.title || "Opportunity",
          company: opportunity.company || null,
        },

        matchingSkills,

        missingSkills,

        readinessPercentage,

        recommendation:
          readinessPercentage >= 80
            ? "Strong skill match"
            : readinessPercentage >= 50
              ? "Moderate skill match"
              : "Skill development recommended",
      },
    });
  } catch (error) {
    console.error(
      "Opportunity readiness analysis error:",
      error
    );

    return res.status(500).json({
      message: "Failed to analyze opportunity readiness",
      status: "error",
    });
  }
};

module.exports = {
  analyzeOpportunityReadiness,
};