const prisma = require("../config/database");

// Get all notifications for current user
const getMyNotifications = async (req, res) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.userId },
      orderBy: { createdAt: "desc" },
      take: 50,
    });

    const unreadCount = await prisma.notification.count({
      where: {
        userId: req.user.userId,
        isRead: false,
      },
    });

    return res.status(200).json({
      status: "success",
      notifications,
      unreadCount,
    });
  } catch (error) {
    console.error("Get notifications error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to retrieve notifications",
    });
  }
};

// Mark single notification as read
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await prisma.notification.updateMany({
      where: {
        id: Number(id),
        userId: req.user.userId,
      },
      data: { isRead: true },
    });

    return res.status(200).json({
      status: "success",
      message: "Notification marked as read",
    });
  } catch (error) {
    console.error("Mark notification read error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to update notification",
    });
  }
};

// Mark all notifications as read
const markAllAsRead = async (req, res) => {
  try {
    await prisma.notification.updateMany({
      where: {
        userId: req.user.userId,
        isRead: false,
      },
      data: { isRead: true },
    });

    return res.status(200).json({
      status: "success",
      message: "All notifications marked as read",
    });
  } catch (error) {
    console.error("Mark all notifications read error:", error);
    return res.status(500).json({
      status: "error",
      message: "Failed to mark all notifications as read",
    });
  }
};

module.exports = {
  getMyNotifications,
  markAsRead,
  markAllAsRead,
};
