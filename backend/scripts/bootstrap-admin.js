require("dotenv").config();

const bcrypt = require("bcrypt");
const prisma = require("../src/config/database");

const email = process.env.ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.ADMIN_PASSWORD;

if (!email || !password) {
  console.error("ADMIN_EMAIL and ADMIN_PASSWORD must be set.");
  process.exit(1);
}

if (password.length < 8) {
  console.error("ADMIN_PASSWORD must be at least 8 characters long.");
  process.exit(1);
}

async function main() {
  const hashedPassword = await bcrypt.hash(password, 10);
  const existingUser = await prisma.user.findUnique({ where: { email } });

  const user = existingUser
    ? await prisma.user.update({
        where: { id: existingUser.id },
        data: { password: hashedPassword, role: "ADMIN" },
      })
    : await prisma.user.create({
        data: { email, password: hashedPassword, role: "ADMIN" },
      });

  console.log(`Administrator account is ready for ${user.email}.`);
}

main()
  .catch((error) => {
    console.error("Unable to bootstrap administrator account:", error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
