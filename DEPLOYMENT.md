# Deploying Unify

This repository has three deployable parts:

| Part | Service | Repository root directory |
| --- | --- | --- |
| API | Railway | `backend` |
| Admin dashboard | Vercel | `admin` |
| Flutter application | Google Play / App Store | `mobile` |

Use a managed PostgreSQL database such as Neon. The database is used only by
the Railway API; do not expose its connection string to Vercel or the mobile
app.

## 1. Create the database

1. Create a Neon PostgreSQL project in the region closest to your users.
2. Copy its pooled connection string.
3. Keep the connection string private. It becomes the Railway `DATABASE_URL`
   variable.

## 2. Deploy the API on Railway

1. Push this repository to a private GitHub repository.
2. In Railway, create a service from the repository and set **Root Directory**
   to `backend`.
3. Attach a Railway Volume and mount it at `/data`.
4. Add the following Railway variables. Values in angle brackets must be
   replaced; never commit them.

   ```text
   NODE_ENV=production
   DATABASE_URL=<Neon pooled PostgreSQL connection string>
   JWT_SECRET=<a newly generated 32+ character random secret>
   GEMINI_API_KEY=<Gemini API key>
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=465
   SMTP_SECURE=true
   SMTP_USER=<SMTP account>
   SMTP_PASSWORD=<new SMTP app password>
   MAIL_FROM="Unify <no-reply@your-domain.example>"
   UPLOAD_DIR=/data
   PUBLIC_BASE_URL=https://<your-railway-api-domain>
   CORS_ORIGINS=https://<your-vercel-admin-domain>
   ```

5. Deploy. `railway.json` installs dependencies, generates Prisma Client,
   deploys database migrations, starts the API, and checks `/api/health`.
6. Generate a public Railway domain, or map `api.your-domain.example` to the
   service. Use that exact HTTPS address for `PUBLIC_BASE_URL`.

For Vercel preview builds, temporarily add each preview origin to
`CORS_ORIGINS`, or use a dedicated staging frontend domain.

## 3. Deploy the admin dashboard on Vercel

1. Import the same GitHub repository into Vercel and set **Root Directory** to
   `admin`.
2. Add this Production environment variable:

   ```text
   VITE_API_BASE_URL=https://<your-railway-api-domain>/api
   ```

3. Deploy and copy the resulting `https://...vercel.app` URL.
4. Add that URL to Railway's `CORS_ORIGINS`, then redeploy the API.

`VITE_API_BASE_URL` is public build-time configuration. Do not put secrets in
variables beginning with `VITE_`.

## 4. Release the Flutter app

Build with the deployed API URL:

```powershell
cd mobile
flutter build appbundle --dart-define=API_BASE_URL=https://<your-railway-api-domain>
```

The resulting Android App Bundle is at
`build\app\outputs\bundle\release\app-release.aab`. Before Play Store
submission, replace the placeholder Android application ID
`com.example.mobile`, configure a release signing key, and register the
matching SHA-1/SHA-256 fingerprints in Firebase/Google OAuth.

## Security checklist

- Rotate the Gmail app password and JWT secret that were previously committed
  in `backend/.env.example`. They must be treated as compromised.
- Store all new secrets only in Railway's environment-variable settings.
- The tracked test resumes have been removed from Git tracking and the upload
  directory is ignored. They remain on your local machine.
- The Railway volume keeps uploaded files across deployments. For multiple API
  replicas or higher-scale production, migrate resume storage to S3, Cloudinary,
  or Supabase Storage.
- Set up a custom domain and HTTPS before sharing the app publicly.
