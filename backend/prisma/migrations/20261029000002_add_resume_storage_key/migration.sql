-- Retain the Cloudinary public ID so a resume can be replaced or deleted safely.
ALTER TABLE "StudentProfile"
  ADD COLUMN "resumeStorageKey" TEXT;
