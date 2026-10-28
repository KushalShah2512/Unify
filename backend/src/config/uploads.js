const fs = require("fs");
const path = require("path");

// In Railway, set UPLOAD_DIR to a mounted Volume path (for example /data).
// The local default keeps the existing development workflow unchanged.
const uploadRoot = process.env.UPLOAD_DIR
  ? path.resolve(process.env.UPLOAD_DIR)
  : path.resolve(__dirname, "../../uploads");
const resumeUploadDir = path.join(uploadRoot, "resumes");

fs.mkdirSync(resumeUploadDir, { recursive: true });

module.exports = { uploadRoot, resumeUploadDir };
