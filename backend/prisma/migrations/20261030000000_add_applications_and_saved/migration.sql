-- CreateTable
CREATE TABLE IF NOT EXISTS "Application" (
    "id" SERIAL NOT NULL,
    "studentId" INTEGER NOT NULL,
    "opportunityId" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'APPLIED',
    "coverLetter" TEXT,
    "appliedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Application_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "Notification" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'APPLICATION',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "SavedOpportunity" (
    "id" SERIAL NOT NULL,
    "studentId" INTEGER NOT NULL,
    "opportunityId" INTEGER NOT NULL,
    "savedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SavedOpportunity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "OpportunityReport" (
    "id" SERIAL NOT NULL,
    "opportunityId" INTEGER NOT NULL,
    "studentId" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "details" TEXT,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OpportunityReport_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "Application_studentId_opportunityId_key" ON "Application"("studentId", "opportunityId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "SavedOpportunity_studentId_opportunityId_key" ON "SavedOpportunity"("studentId", "opportunityId");

-- AddForeignKey
ALTER TABLE "Application" DROP CONSTRAINT IF EXISTS "Application_studentId_fkey";
ALTER TABLE "Application" ADD CONSTRAINT "Application_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Application" DROP CONSTRAINT IF EXISTS "Application_opportunityId_fkey";
ALTER TABLE "Application" ADD CONSTRAINT "Application_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "Opportunity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" DROP CONSTRAINT IF EXISTS "Notification_userId_fkey";
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SavedOpportunity" DROP CONSTRAINT IF EXISTS "SavedOpportunity_studentId_fkey";
ALTER TABLE "SavedOpportunity" ADD CONSTRAINT "SavedOpportunity_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SavedOpportunity" DROP CONSTRAINT IF EXISTS "SavedOpportunity_opportunityId_fkey";
ALTER TABLE "SavedOpportunity" ADD CONSTRAINT "SavedOpportunity_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "Opportunity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpportunityReport" DROP CONSTRAINT IF EXISTS "OpportunityReport_opportunityId_fkey";
ALTER TABLE "OpportunityReport" ADD CONSTRAINT "OpportunityReport_opportunityId_fkey" FOREIGN KEY ("opportunityId") REFERENCES "Opportunity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpportunityReport" DROP CONSTRAINT IF EXISTS "OpportunityReport_studentId_fkey";
ALTER TABLE "OpportunityReport" ADD CONSTRAINT "OpportunityReport_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
