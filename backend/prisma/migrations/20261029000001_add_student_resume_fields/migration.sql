-- Add the resume fields defined in prisma/schema.prisma.
ALTER TABLE "StudentProfile"
  ADD COLUMN "resumeUrl" TEXT,
  ADD COLUMN "resumeName" TEXT,
  ADD COLUMN "resumeSize" INTEGER,
  ADD COLUMN "resumeUpdatedAt" TIMESTAMP(3),
  ADD COLUMN "isResumeVerified" BOOLEAN NOT NULL DEFAULT false;
