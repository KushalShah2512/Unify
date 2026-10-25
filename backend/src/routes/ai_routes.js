const express = require("express");
const multer = require("multer");

const {
  analyzeOpportunityReadiness,
  careerChat,
  atsResumeChecker,
  conductMockInterview,
} = require("../controllers/ai_controller");

const { authenticateToken } = require("../middleware/auth_middleware");
const { authorizeRoles } = require("../middleware/role_middleware");

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB maximum
});

router.use(authenticateToken);
router.use(authorizeRoles("STUDENT"));

// Analyze Opportunity Readiness
router.post("/opportunity-readiness", analyzeOpportunityReadiness);

// AI Career Assistant Chat
router.post("/career-chat", careerChat);

// Interactive AI Mock Interviewer Simulator
router.post("/mock-interview", conductMockInterview);

// ATS Resume Checker - supports both file uploads (PDF, DOCX, TXT) and JSON/text payloads
router.post("/ats-checker", upload.single("resumeFile"), atsResumeChecker);

module.exports = router;