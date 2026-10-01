/*
  Warnings:

  - You are about to drop the column `endYear` on the `Education` table. All the data in the column will be lost.
  - You are about to drop the column `startYear` on the `Education` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "Education" DROP COLUMN "endYear",
DROP COLUMN "startYear";
