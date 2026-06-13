# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `npm run dev` — start Vite dev server
- `npm run build` — production build to `dist/`
- `npm run preview` — serve the built `dist/` locally

No lint or test scripts are configured.

## Architecture

Single-page React app (Vite + React 18, JSX, no TypeScript) that renders a one-line prompt and dynamically injects a Microsoft Customer Connect chatbot `<script>` tag into the document body on mount. The script is removed on unmount. There is no routing, no state management, and no backend — the entire visible app is the chat bubble served by the injected third-party script.

- `index.html` — Vite entry; includes `noindex` meta tags to block crawlers (paired with `public/robots.txt`)
- `src/main.jsx` → `src/App.jsx` — the only component; the `useEffect` in `App.jsx` is where the chatbot is wired up
- `public/` — files copied verbatim to the build root (`robots.txt`, `sitemap.xml`)
- `CNAME` — custom domain `dev.epel.us` for GitHub Pages

## Deployment

`.github/workflows/deploy.yml` deploys to GitHub Pages on every push to `main`: `npm ci` → `npm run build` → upload `dist/` → `actions/deploy-pages@v4`. There is no dev/test/prod split here — `main` is production. The site is publicly served at `dev.epel.us` but blocked from crawlers via `robots.txt` and meta tags.

## Notes

- This repo is independent of the broader `bbs-*` project described in the user's global CLAUDE.md — the AWS/AppSync/CDK stack and the 4-branch `feature → dev → test → main` flow do **not** apply here. This is a standalone GitHub Pages site.
- The chatbot `environmentId` in `src/App.jsx` differs from the one commented out in `README.md`; the `App.jsx` value is the live one.
