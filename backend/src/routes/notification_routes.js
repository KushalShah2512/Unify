const express = require("express");
const {
  getMyNotifications,
  markAsRead,
  markAllAsRead,
} = require("../controllers/notification_controller");
const { authenticateToken } = require("../middleware/auth_middleware");

const router = express.Router();

router.use(authenticateToken);

router.get("/", getMyNotifications);
router.put("/:id/read", markAsRead);
router.put("/read-all", markAllAsRead);

module.exports = router;
