const prisma = require("../config/database");

const analyzeOpportunityReadiness = async (req, res) => {
  try {
    const { opportunity } = req.body;

    if (!opportunity) {
      return res.status(400).json({
        message: "Opportunity data is required",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
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

    // -----------------------------------------
    // Student skills
    // -----------------------------------------

    const studentSkills = studentProfile.skills.map((skill) =>
      skill.name.toLowerCase().trim()
    );

    // -----------------------------------------
    // Required skills
    // -----------------------------------------

    const requiredSkills = Array.isArray(opportunity.requiredSkills)
      ? opportunity.requiredSkills
      : [];

    const normalizedRequiredSkills = requiredSkills.map((skill) =>
      skill.toLowerCase().trim()
    );

    // -----------------------------------------
    // Skill matching
    // -----------------------------------------

    const matchingSkills = normalizedRequiredSkills.filter((skill) =>
      studentSkills.includes(skill)
    );

    const missingSkills = normalizedRequiredSkills.filter(
      (skill) => !studentSkills.includes(skill)
    );

    // -----------------------------------------
    // Readiness percentage
    // -----------------------------------------

    const readinessPercentage =
      normalizedRequiredSkills.length > 0
        ? Math.round(
            (matchingSkills.length /
              normalizedRequiredSkills.length) *
              100
          )
        : 0;

    // -----------------------------------------
    // Recommendation level
    // -----------------------------------------

    let recommendation;

    if (readinessPercentage >= 80) {
      recommendation = "Strong skill match";
    } else if (readinessPercentage >= 50) {
      recommendation = "Moderate skill match";
    } else {
      recommendation = "Skill development recommended";
    }

    // -----------------------------------------
    // Personalized skill-gap actions
    // -----------------------------------------

    const recommendedActions = [];

    missingSkills.forEach((skill) => {
      switch (skill) {
        case "react":
          recommendedActions.push(
            "Learn React fundamentals and build a small React project."
          );
          break;

        case "javascript":
          recommendedActions.push(
            "Strengthen modern JavaScript fundamentals such as ES6+, promises, and async programming."
          );
          break;

        case "html":
          recommendedActions.push(
            "Revise semantic HTML and build responsive web pages."
          );
          break;

        case "css":
          recommendedActions.push(
            "Practice responsive CSS, Flexbox, Grid, and modern layouts."
          );
          break;

        case "git":
          recommendedActions.push(
            "Practice Git and GitHub workflows such as branching, commits, pull requests, and merging."
          );
          break;

        case "flutter":
          recommendedActions.push(
            "Build a Flutter application using widgets, navigation, state management, and API integration."
          );
          break;

        case "dart":
          recommendedActions.push(
            "Strengthen Dart fundamentals including classes, collections, null safety, and asynchronous programming."
          );
          break;

        case "firebase":
          recommendedActions.push(
            "Learn Firebase authentication, Firestore, and basic cloud integration."
          );
          break;

        case "node.js":
          recommendedActions.push(
            "Build REST APIs using Node.js and Express.js."
          );
          break;

        case "express.js":
          recommendedActions.push(
            "Practice building REST APIs, middleware, authentication, and error handling with Express.js."
          );
          break;

        case "mongodb":
          recommendedActions.push(
            "Practice MongoDB CRUD operations, schema design, and database queries."
          );
          break;

        case "rest api":
          recommendedActions.push(
            "Practice designing and consuming REST APIs using HTTP methods, JSON, and authentication."
          );
          break;

        default:
          recommendedActions.push(
            `Develop practical skills in ${skill} through a small project or hands-on practice.`
          );
      }
    });

    // Limit recommendations to avoid an unnecessarily long response.
    const limitedRecommendedActions =
      recommendedActions.slice(0, 5);

    // -----------------------------------------
    // Why this matters
    // -----------------------------------------

    let readinessMessage;

    if (missingSkills.length === 0) {
      readinessMessage =
        "Your current skills cover all the required skills listed for this opportunity.";
    } else if (readinessPercentage >= 50) {
      readinessMessage =
        `You already match ${matchingSkills.length} of ${normalizedRequiredSkills.length} required skills. Improving the remaining skills can strengthen your application.`;
    } else {
      readinessMessage =
        `You currently match ${matchingSkills.length} of ${normalizedRequiredSkills.length} required skills. Building the missing skills will improve your readiness for this opportunity.`;
    }

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

        recommendation,

        readinessMessage,

        recommendedActions: limitedRecommendedActions,
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