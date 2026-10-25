const prisma = require("../config/database");
const { GoogleGenAI } = require("@google/genai");

// Helper to get Gemini client
const getGeminiClient = () => {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey.trim() === "") return null;
  return new GoogleGenAI({ apiKey });
};

// =========================================================
// 1. Opportunity Readiness Analyzer
// =========================================================
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

    const studentSkills = studentProfile.skills.map((skill) =>
      skill.name.toLowerCase().trim()
    );

    const requiredSkills = Array.isArray(opportunity.requiredSkills)
      ? opportunity.requiredSkills
      : [];

    const normalizedRequiredSkills = requiredSkills.map((skill) =>
      skill.toLowerCase().trim()
    );

    const matchingSkills = normalizedRequiredSkills.filter((skill) =>
      studentSkills.includes(skill)
    );

    const missingSkills = normalizedRequiredSkills.filter(
      (skill) => !studentSkills.includes(skill)
    );

    const readinessPercentage =
      normalizedRequiredSkills.length > 0
        ? Math.round((matchingSkills.length / normalizedRequiredSkills.length) * 100)
        : 0;

    let recommendation;
    if (readinessPercentage >= 80) {
      recommendation = "Strong skill match";
    } else if (readinessPercentage >= 50) {
      recommendation = "Moderate skill match";
    } else {
      recommendation = "Skill development recommended";
    }

    const recommendedActions = [];
    missingSkills.forEach((skill) => {
      switch (skill) {
        case "react":
          recommendedActions.push("Learn React fundamentals and build a component project.");
          break;
        case "javascript":
          recommendedActions.push("Strengthen modern JavaScript fundamentals (ES6+, Promises, async/await).");
          break;
        case "flutter":
          recommendedActions.push("Build a cross-platform Flutter application with state management.");
          break;
        case "node.js":
          recommendedActions.push("Practice creating REST APIs and database integrations using Node.js & Express.");
          break;
        case "sql":
        case "postgresql":
          recommendedActions.push("Practice SQL queries, relational schema modeling, and indexing.");
          break;
        case "docker":
          recommendedActions.push("Learn containerization basics with Docker and containerize a web app.");
          break;
        default:
          recommendedActions.push(`Develop hands-on experience in ${skill} through practical mini-projects.`);
      }
    });

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
        recommendedActions: recommendedActions.slice(0, 5),
      },
    });
  } catch (error) {
    console.error("Opportunity readiness analysis error:", error);
    return res.status(500).json({
      message: "Failed to analyze opportunity readiness",
      status: "error",
    });
  }
};

// =========================================================
// 2. Gemini AI Career Assistant Chat
// =========================================================
const careerChat = async (req, res) => {
  try {
    const { message, conversationHistory = [] } = req.body;

    if (!message || message.trim() === "") {
      return res.status(400).json({
        message: "Message is required",
        status: "error",
      });
    }

    // Fetch student context for rich personalization
    const profile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
      include: {
        skills: true,
        projects: true,
        educationRecords: true,
        certifications: true,
      },
    });

    const studentName = profile?.fullName || "Student";
    const careerGoal = profile?.careerGoal || "Software Engineering";
    const skillsList = profile?.skills?.map((s) => s.name).join(", ") || "General computing";
    const projectsList = profile?.projects?.map((p) => p.title).join(", ") || "None listed yet";

    const ai = getGeminiClient();

    if (ai) {
      try {
        const systemPrompt = `You are Unify's AI Career Assistant, a warm, highly knowledgeable, and strategic career coach, technical mentor, and interview advisor.
Student Context:
- Name: ${studentName}
- Career Goal: ${careerGoal}
- Current Skills: ${skillsList}
- Portfolio Projects: ${projectsList}

Guidelines:
- Give direct, actionable, practical advice.
- Use formatting (bullet points, clear headings, bold text) for readability.
- Tailor suggestions specifically to their career goal and skill profile.
- If asked about mock interviews, ask them one relevant question at a time and critique their answers constructively.
- Keep the tone encouraging, professional, and forward-looking.`;

        const fullPrompt = `${systemPrompt}\n\nStudent question: "${message}"`;
        const response = await ai.models.generateContent({
          model: "gemini-2.5-flash",
          contents: fullPrompt,
        });

        const reply = response.text || "I am here to guide your career path and opportunity readiness.";

        return res.status(200).json({
          status: "success",
          reply,
          source: "gemini",
        });
      } catch (geminiError) {
        console.error("Gemini API call failed, using built-in career engine:", geminiError.message);
      }
    }

    // Intelligent built-in fallback response generator
    const lower = message.toLowerCase();
    let reply = "";

    if (lower.includes("interview") || lower.includes("question")) {
      reply = `### 🎯 Interview Preparation for ${careerGoal}\n\nHere are the top 3 interview questions to practice for your target role:\n\n1. **Technical Depth:** "Can you explain how you structured the architecture of your ${projectsList !== "None listed yet" ? projectsList.split(",")[0] : "recent project"}, and what trade-offs you made?"\n2. **Problem Solving:** "How do you handle debugging when an unexpected API or database error occurs in production?"\n3. **Behavioral (STAR Method):** "Describe a challenging technical hurdle you faced and how you overcame it."\n\n💡 **Tip:** Structure your answers using **Situation, Task, Action, and Result (STAR)**.`;
    } else if (lower.includes("resume") || lower.includes("cv")) {
      reply = `### 📄 Resume Enhancement Tips for ${studentName}\n\nBased on your current profile:\n\n- **Highlight Core Skills:** Make sure your top skills (${skillsList}) appear in your summary and project descriptions.\n- **Quantify Impact:** Instead of *"built a web app"*, write *"Engineered a responsive app with 5+ core features, reducing latency by 30%"*.\n- **Action Verbs:** Start every bullet point with strong action verbs like *Architected*, *Implemented*, *Optimized*, or *Deployed*.\n- **Targeting:** Tailor your resume keywords specifically to each job description to pass ATS filters.`;
    } else if (lower.includes("roadmap") || lower.includes("learn") || lower.includes("skill")) {
      reply = `### 🚀 Career Roadmap for ${careerGoal}\n\nTo advance toward your goal, here is your recommended 3-step milestone plan:\n\n1. **Phase 1 (Core Mastery):** Solidify fundamentals in your core stack (${skillsList}).\n2. **Phase 2 (Production Portfolio):** Build 2 end-to-end full-stack projects featuring authentication, database migrations, and CI/CD deployment.\n3. **Phase 3 (Networking & Application):** Optimize your Unify Career Passport, contribute to open source, and apply for high-match opportunities on the portal.`;
    } else {
      reply = `Hello ${studentName}! As your Unify AI Career Advisor, I am here to help you achieve your career goal as a **${careerGoal}**.\n\nHere are some things we can do together:\n\n- 💼 **Mock Interview Practice:** Ask me to conduct a mock interview for ${careerGoal}.\n- 📄 **Resume Review:** Ask how to tailor your resume and showcase your projects.\n- 📈 **Skill Gap Analysis:** Ask what technologies to learn next to increase your hiring readiness.\n\nWhat would you like to explore today?`;
    }

    return res.status(200).json({
      status: "success",
      reply,
      source: "expert_engine",
    });
  } catch (error) {
    console.error("Career chat error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to generate AI career advice",
    });
  }
};

// Helper to extract text from uploaded resume file (PDF, DOCX, TXT)
const extractTextFromFile = async (file) => {
  if (!file || !file.buffer) return "";

  const originalName = file.originalname ? file.originalname.toLowerCase() : "";
  const mimeType = file.mimetype ? file.mimetype.toLowerCase() : "";

  // 1. PDF files
  if (originalName.endsWith(".pdf") || mimeType.includes("pdf")) {
    try {
      const { PDFParse } = require("pdf-parse");
      const parser = new PDFParse({ data: file.buffer });
      const res = await parser.getText();
      await parser.destroy();
      if (res && res.text && res.text.trim().length > 0) {
        return res.text;
      }
    } catch (err) {
      console.error("PDF parse error:", err.message);
    }
  }

  // 2. Word (.docx) files
  if (originalName.endsWith(".docx") || mimeType.includes("wordprocessingml") || mimeType.includes("docx")) {
    try {
      const mammoth = require("mammoth");
      const res = await mammoth.extractRawText({ buffer: file.buffer });
      if (res && res.value && res.value.trim().length > 0) {
        return res.value;
      }
    } catch (err) {
      console.error("DOCX parse error:", err.message);
    }
  }

  // 3. Fallback: UTF-8 plain text
  try {
    return file.buffer.toString("utf-8");
  } catch (err) {
    return "";
  }
};

// =========================================================
// 3. ATS Resume Checker
// =========================================================
const atsResumeChecker = async (req, res) => {
  try {
    const { targetRole, jobDescription, customResumeText } = req.body;

    let fileResumeText = "";
    if (req.file) {
      fileResumeText = await extractTextFromFile(req.file);
    }

    const profile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
      include: {
        skills: true,
        projects: true,
        educationRecords: true,
        certifications: true,
      },
    });

    const hasFile = fileResumeText && fileResumeText.trim() !== "";
    const hasCustomText = customResumeText && customResumeText.trim() !== "";
    if (!profile && !hasCustomText && !hasFile) {
      return res.status(400).json({
        status: "error",
        message: "Please upload your resume file (PDF, DOCX, TXT), paste your resume content, or create your student profile first.",
      });
    }

    // Build resume representation
    const skillsText = profile?.skills ? profile.skills.map((s) => s.name).join(", ") : "";
    const projectsText = profile?.projects
      ? profile.projects.map((p) => `${p.title}: ${p.description || ""} (${p.technologies || ""})`).join("\n")
      : "";
    const educationText = profile?.educationRecords
      ? profile.educationRecords.map((e) => `${e.degree} from ${e.institution} (${e.fieldOfStudy || ""})`).join("\n")
      : "";
    const certsText = profile?.certifications ? profile.certifications.map((c) => c.name).join(", ") : "";

    const resumeContent = hasFile
      ? fileResumeText.trim()
      : hasCustomText
      ? customResumeText.trim()
      : `Name: ${profile?.fullName || "Candidate"}\nBio: ${profile?.bio || ""}\nEducation: ${educationText}\nSkills: ${skillsText}\nProjects: ${projectsText}\nCertifications: ${certsText}`;

    const roleToMatch = (targetRole || profile?.careerGoal || "Software Developer").toLowerCase();

    // Context-sensitive keywords based on target job role
    let standardKeywords = [
      "javascript", "react", "node.js", "python", "git", "sql", "api", "rest",
      "database", "testing", "agile", "problem solving", "docker", "flutter",
      "teamwork", "communication", "typescript"
    ];

    if (roleToMatch.includes("data") || roleToMatch.includes("analyst") || roleToMatch.includes("analytics") || roleToMatch.includes("bi")) {
      standardKeywords = [
        "sql", "python", "excel", "data analysis", "tableau", "power bi", "statistics",
        "machine learning", "etl", "database", "analytics", "visualization", "r",
        "reporting", "metrics", "pandas", "data modeling"
      ];
    } else if (roleToMatch.includes("flutter") || roleToMatch.includes("mobile") || roleToMatch.includes("android") || roleToMatch.includes("ios")) {
      standardKeywords = [
        "flutter", "dart", "mobile", "rest api", "state management", "git", "firebase",
        "widget", "bloc", "riverpod", "provider", "ui/ux", "offline storage"
      ];
    }

    const resumeLower = resumeContent.toLowerCase();

    const matchedKeywords = standardKeywords.filter((kw) => resumeLower.includes(kw));
    const missingKeywords = standardKeywords.filter((kw) => !resumeLower.includes(kw)).slice(0, 6);

    // Scoring calculation with null-safe profile checks
    const hasEducation = (profile?.educationRecords?.length || 0) > 0 ||
      resumeLower.includes("degree") || resumeLower.includes("bachelor") || resumeLower.includes("master") || resumeLower.includes("diploma") || resumeLower.includes("certificate") || resumeLower.includes("university");
    const hasProjects = (profile?.projects?.length || 0) > 0 ||
      resumeLower.includes("project") || resumeLower.includes("internship") || resumeLower.includes("experience") || resumeLower.includes("worked");
    const hasSkills = (profile?.skills?.length || 0) >= 3 || matchedKeywords.length >= 3;
    const hasCertifications = (profile?.certifications?.length || 0) > 0 ||
      resumeLower.includes("certificate") || resumeLower.includes("certified") || resumeLower.includes("completion");

    let keywordScore = Math.min(100, Math.round((matchedKeywords.length / Math.min(6, standardKeywords.length)) * 100));
    let structureScore = (hasEducation ? 25 : 0) + (hasProjects ? 35 : 0) + (hasSkills ? 25 : 0) + (hasCertifications ? 15 : 0);
    let impactScore = resumeLower.includes("%") || resumeLower.includes("reduced") || resumeLower.includes("improved") || resumeLower.includes("achieved") || resumeLower.includes("increased") ? 85 : 60;

    const overallScore = Math.min(100, Math.round((keywordScore * 0.4) + (structureScore * 0.35) + (impactScore * 0.25)));

    let scoreRating = "Needs Optimization";
    if (overallScore >= 80) scoreRating = "Excellent - Highly ATS Ready";
    else if (overallScore >= 65) scoreRating = "Good - Competitive";
    else if (overallScore >= 50) scoreRating = "Average - Minor Fixes Needed";

    const feedback = [];
    if (!hasProjects) {
      feedback.push("Add at least 2 detailed projects or practical experiences with metrics.");
    }
    if (impactScore < 70) {
      feedback.push("Include measurable business outcomes (e.g., 'improved performance by 25%', 'analyzed 10k+ rows').");
    }
    if (missingKeywords.length > 0) {
      feedback.push(`Incorporate high-demand ATS keywords: ${missingKeywords.slice(0, 4).join(", ")}.`);
    }
    feedback.push("Ensure your section headings (Experience, Education, Skills) follow clear standard naming.");

    // If Gemini is available, enhance with AI insights
    const ai = getGeminiClient();
    let aiCritique = null;

    if (ai) {
      try {
        const prompt = `You are an executive ATS (Applicant Tracking System) specialist and resume auditor.
Candidate applying for: ${roleToMatch}
Resume Content:
${resumeContent}

Provide a concise 3-bullet evaluation:
1. Strongest competitive asset.
2. The single highest-impact keyword or skill to add.
3. Formatting or phrasing improvement recommendation.`;

        const res = await ai.models.generateContent({
          model: "gemini-2.5-flash",
          contents: prompt,
        });

        aiCritique = res.text;
      } catch (err) {
        console.error("Gemini ATS enhancement error:", err.message);
      }
    }

    return res.status(200).json({
      status: "success",
      atsReport: {
        source: req.file ? "uploaded_file" : hasCustomText ? "pasted_text" : "profile",
        fileName: req.file ? req.file.originalname : null,
        targetRole: roleToMatch,
        overallScore,
        scoreRating,
        breakdown: {
          keywordMatch: keywordScore,
          sectionStructure: structureScore,
          impactAndMetrics: impactScore,
        },
        matchedKeywords,
        missingKeywords,
        feedback,
        aiCritique,
      },
    });
  } catch (error) {
    console.error("ATS Resume Checker error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to evaluate ATS resume score",
    });
  }
};

// =========================================================
// 4. Interactive AI Mock Interviewer Simulator
// =========================================================
const conductMockInterview = async (req, res) => {
  try {
    const {
      role = "Full Stack Developer",
      type = "technical",
      currentQuestionNumber = 1,
      previousQuestion = null,
      candidateAnswer = null,
    } = req.body;

    // Fetch student's profile for personalized questions
    const profile = await prisma.studentProfile.findUnique({
      where: { userId: req.user.userId },
      include: { skills: true, projects: true },
    });

    const studentName = profile?.fullName || "Candidate";
    const studentSkills = profile?.skills?.map((s) => s.name).join(", ") || "General computing";

    const ai = getGeminiClient();

    // Built-in question bank for fallbacks
    const roleQuestions = {
      technical: [
        `Can you explain the difference between synchronous and asynchronous operations, and how the event loop manages async execution?`,
        `Describe how you design and structure a RESTful or GraphQL API to handle high concurrency and protect against rate limiting.`,
        `Walk me through an edge-case bug or performance bottleneck you resolved in one of your recent projects (${profile?.projects?.[0]?.title || "web/mobile app"}).`,
        `How do you manage state and data persistence across distributed or client-server architectures?`,
        `If your application's database queries start slowing down significantly under load, what diagnostic steps and optimizations would you apply?`,
      ],
      behavioral: [
        `Tell me about a time you faced an ambiguous requirement or unexpected roadblock during a project. How did you handle it?`,
        `Describe a situation where you had a technical disagreement with a teammate. How did you reach a consensus?`,
        `How do you prioritize competing deadlines when multiple tasks or bug reports demand your immediate attention?`,
        `Can you share an experience where you had to quickly learn and adopt a new technology or framework under tight delivery timelines?`,
        `Tell me about a project you are most proud of. What was your personal contribution and measurable outcome?`,
      ],
      mixed: [
        `Walk me through your background, technical interests, and why you are targeting the ${role} position.`,
        `Explain how you ensure security and proper input sanitization when accepting user input in web and mobile applications.`,
        `Tell me about a time when you received constructive or critical feedback on your code. How did you respond?`,
        `How do you approach testing, error logging, and monitoring in your applications before pushing to production?`,
        `Where do you see the future of ${role} evolving over the next 2-3 years, and how are you preparing for it?`,
      ],
    };

    const questionsList = roleQuestions[type] || roleQuestions.technical;

    // Case 1: Starting the mock interview (Question 1)
    if (!candidateAnswer || candidateAnswer.trim() === "") {
      let initialQuestion = questionsList[0];

      if (ai) {
        try {
          const prompt = `You are a Senior Technical Hiring Manager conducting a ${type} interview for a ${role} position.
Candidate Name: ${studentName}
Candidate Skills: ${studentSkills}

Generate Question #1 to open this interview. Keep it professional, realistic, and directly relevant to a junior/mid ${role}. Return only the question text.`;

          const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: prompt,
          });

          if (response.text && response.text.trim()) {
            initialQuestion = response.text.trim();
          }
        } catch (err) {
          console.error("Gemini mock interview init error:", err.message);
        }
      }

      return res.status(200).json({
        status: "success",
        interview: {
          role,
          type,
          questionNumber: 1,
          totalQuestions: 5,
          isCompleted: false,
          question: initialQuestion,
          welcomeMessage: `Welcome ${studentName}! I am your AI Interviewer for the ${role} position (${type.toUpperCase()} round). Answer naturally with real examples, and submit your response when ready.`,
        },
      });
    }

    // Case 2: Candidate has submitted an answer to previousQuestion
    const nextQNum = Number(currentQuestionNumber) + 1;
    const isCompleted = nextQNum > 5;

    let evaluation = {
      score: 8,
      strengths: "Clear structure and directly addressed the core question.",
      improvementAreas: "Consider including specific metrics, real-world constraints, or mentioning edge cases.",
      idealAnswer: "A comprehensive response should define the core concept, provide a concrete implementation example, and highlight trade-offs or scalability considerations.",
      nextQuestion: isCompleted ? null : (questionsList[nextQNum - 1] || questionsList[nextQNum - 1] || "Tell me how you would design a scalable caching strategy."),
    };

    if (ai) {
      try {
        const prompt = `You are an expert Technical Interviewer evaluating a candidate's response for a ${role} interview.
Candidate: ${studentName}
Round Type: ${type}
Question #${currentQuestionNumber}: "${previousQuestion || questionsList[Math.max(0, currentQuestionNumber - 1)]}"
Candidate's Answer: "${candidateAnswer}"

${isCompleted 
  ? "This was the final question (Question 5). Evaluate their answer, give overall performance feedback, and set nextQuestion to null."
  : `Evaluate their answer and generate Question #${nextQNum} of 5 for this ${role} interview.`
}

Return your response in STRICT valid JSON format with keys:
{
  "score": <number between 1 and 10>,
  "strengths": "<concise summary of what the candidate answered well>",
  "improvementAreas": "<actionable critique, missed technical nuances, or framework suggestions like STAR method>",
  "idealAnswer": "<a concise 2-3 sentence benchmark model answer demonstrating top candidate depth>",
  "nextQuestion": ${isCompleted ? "null" : '"<the next interview question text>"'},
  "overallSummary": ${isCompleted ? '"<2-3 sentences evaluating total interview readiness, strengths, and hire recommendation>"' : "null"}
}`;

        const response = await ai.models.generateContent({
          model: "gemini-2.5-flash",
          contents: prompt,
        });

        const rawText = response.text || "";
        const jsonMatch = rawText.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0]);
          evaluation = {
            score: Number(parsed.score) || 7.5,
            strengths: parsed.strengths || evaluation.strengths,
            improvementAreas: parsed.improvementAreas || evaluation.improvementAreas,
            idealAnswer: parsed.idealAnswer || evaluation.idealAnswer,
            nextQuestion: isCompleted ? null : (parsed.nextQuestion || questionsList[nextQNum - 1]),
            overallSummary: parsed.overallSummary || null,
          };
        }
      } catch (err) {
        console.error("Gemini answer evaluation error:", err.message);
        // Fallback scoring based on length and keyword depth
        const wordCount = candidateAnswer.trim().split(/\s+/).length;
        const score = wordCount > 60 ? 8.5 : wordCount > 25 ? 7.0 : 5.5;
        evaluation.score = score;
        if (isCompleted) {
          evaluation.overallSummary = `Great effort completing all 5 interview rounds! You demonstrated solid fundamental knowledge for the ${role} position. Focus on structuring responses with STAR framework and quantifying outcomes.`;
        }
      }
    }

    return res.status(200).json({
      status: "success",
      interview: {
        role,
        type,
        evaluatedQuestionNumber: Number(currentQuestionNumber),
        score: evaluation.score,
        strengths: evaluation.strengths,
        improvementAreas: evaluation.improvementAreas,
        idealAnswer: evaluation.idealAnswer,
        isCompleted,
        nextQuestionNumber: isCompleted ? null : nextQNum,
        nextQuestion: isCompleted ? null : evaluation.nextQuestion,
        overallSummary: evaluation.overallSummary || null,
      },
    });
  } catch (error) {
    console.error("Mock interview error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to conduct mock interview session",
    });
  }
};

module.exports = {
  analyzeOpportunityReadiness,
  careerChat,
  atsResumeChecker,
  conductMockInterview,
};