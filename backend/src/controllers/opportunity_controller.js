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

module.exports = {
  getOpportunities,
};