const prisma = require("../config/database");

// ====================
// Add Certification
// ====================

const addCertification = async (req, res) => {
  try {
    const {
      name,
      issuingOrg,
      issueDate,
      credentialUrl,
    } = req.body;

    if (!name) {
      return res.status(400).json({
        message: "Certification name is required",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const certification = await prisma.certification.create({
      data: {
        name,
        issuingOrg,
        issueDate: issueDate ? new Date(issueDate) : null,
        credentialUrl,
        studentId: studentProfile.id,
      },
    });

    return res.status(201).json({
      message: "Certification added successfully",
      status: "success",
      certification,
    });
  } catch (error) {
    console.error("Add certification error:", error);

    return res.status(500).json({
      message: "Failed to add certification",
      status: "error",
    });
  }
};


// ====================
// Get Certifications
// ====================

const getCertifications = async (req, res) => {
  try {
    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const certifications = await prisma.certification.findMany({
      where: {
        studentId: studentProfile.id,
      },
      orderBy: {
        issueDate: "desc",
      },
    });

    return res.status(200).json({
      message: "Certifications retrieved successfully",
      status: "success",
      certifications,
    });
  } catch (error) {
    console.error("Get certifications error:", error);

    return res.status(500).json({
      message: "Failed to retrieve certifications",
      status: "error",
    });
  }
};


// ====================
// Update Certification
// ====================

const updateCertification = async (req, res) => {
  try {
    const certificationId = parseInt(req.params.id);

    const {
      name,
      issuingOrg,
      issueDate,
      credentialUrl,
    } = req.body;

    if (isNaN(certificationId)) {
      return res.status(400).json({
        message: "Invalid certification ID",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const existingCertification =
      await prisma.certification.findFirst({
        where: {
          id: certificationId,
          studentId: studentProfile.id,
        },
      });

    if (!existingCertification) {
      return res.status(404).json({
        message: "Certification not found",
        status: "error",
      });
    }

    const certification = await prisma.certification.update({
      where: {
        id: certificationId,
      },
      data: {
        name,
        issuingOrg,
        issueDate: issueDate ? new Date(issueDate) : null,
        credentialUrl,
      },
    });

    return res.status(200).json({
      message: "Certification updated successfully",
      status: "success",
      certification,
    });
  } catch (error) {
    console.error("Update certification error:", error);

    return res.status(500).json({
      message: "Failed to update certification",
      status: "error",
    });
  }
};


// ====================
// Delete Certification
// ====================

const deleteCertification = async (req, res) => {
  try {
    const certificationId = parseInt(req.params.id);

    if (isNaN(certificationId)) {
      return res.status(400).json({
        message: "Invalid certification ID",
        status: "error",
      });
    }

    const studentProfile = await prisma.studentProfile.findUnique({
      where: {
        userId: req.user.userId,
      },
    });

    if (!studentProfile) {
      return res.status(404).json({
        message: "Student profile not found",
        status: "error",
      });
    }

    const existingCertification =
      await prisma.certification.findFirst({
        where: {
          id: certificationId,
          studentId: studentProfile.id,
        },
      });

    if (!existingCertification) {
      return res.status(404).json({
        message: "Certification not found",
        status: "error",
      });
    }

    await prisma.certification.delete({
      where: {
        id: certificationId,
      },
    });

    return res.status(200).json({
      message: "Certification deleted successfully",
      status: "success",
    });
  } catch (error) {
    console.error("Delete certification error:", error);

    return res.status(500).json({
      message: "Failed to delete certification",
      status: "error",
    });
  }
};


module.exports = {
  addCertification,
  getCertifications,
  updateCertification,
  deleteCertification,
};