const bcrypt = require("bcrypt");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function resetPassword() {
  const email = "student@test.com";
  const newPassword = "Student@123";

  const hashedPassword = await bcrypt.hash(newPassword, 10);

  const user = await prisma.user.update({
    where: { email },
    data: { password: hashedPassword },
  });

  console.log("Password reset successfully!");
  console.log("Email:", user.email);
  console.log("New Password:", newPassword);
}

resetPassword()
  .catch((error) => {
    console.error("Password reset failed:");
    console.error(error);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });