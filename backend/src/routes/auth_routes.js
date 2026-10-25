const express = require("express");

const {
  register,
  login,
  googleLogin,
  requestPasswordReset,
  resetPassword,
} = require("../controllers/auth_controller");

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/google", googleLogin);
router.post("/forgot-password", requestPasswordReset);
router.post("/reset-password", resetPassword);

module.exports = router;
