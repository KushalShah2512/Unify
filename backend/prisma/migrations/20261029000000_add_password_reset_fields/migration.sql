-- Add the password-reset fields defined in prisma/schema.prisma.
ALTER TABLE "User"
  ADD COLUMN "passwordResetToken" TEXT,
  ADD COLUMN "passwordResetExpires" TIMESTAMP(3);
