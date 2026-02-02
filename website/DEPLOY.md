# Deployment Instructions for SecureVault Website

## GitHub Pages (Static Export)

1.  **Configure `next.config.ts`** (Already done):
    Ensure `output: 'export'` and `images: { unoptimized: true }` are set.

2.  **Build the Project**:
    Run `npm run build` locally to verify. This creates an `out` folder.

3.  **Deploy Action**:
    - Commit your code to GitHub.
    - Go to Repository Settings -> Pages.
    - Source: GitHub Actions (or Deploy from branch).
    - If using "Deploy from branch" (classic), push the `out` folder content to a `gh-pages` branch.
    - Better: Use a GitHub Action. Create `.github/workflows/nextjs.yml` (standard template).

## Vercel (Recommended)

1.  Push code to GitHub.
2.  Import project in Vercel.
3.  Framework Preset: Next.js.
4.  Build Command: `next build` (Vercel handles it automatically).
5.  Deploy.

## Local Testing

Run `npm run dev` to see the site at `http://localhost:3000`.
Run `npx serve out` after building to test the static export.
