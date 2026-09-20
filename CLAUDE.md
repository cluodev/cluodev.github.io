# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal tech blog built with **Astro 5**, using React for interactive components, Tailwind CSS for styling, and MDX for blog posts. It deploys to GitHub Pages automatically on push to `master`, with an automated Bluesky social posting pipeline.

## Commands

Use `yarn` (not `npm`) for this project:

```bash
yarn dev              # Start dev server at http://localhost:4321
yarn build            # Full production build (generates OG images via Puppeteer)
yarn ci               # CI workflow: astro check + build + OG images
yarn preview          # Preview production build
yarn format           # Format with Prettier
yarn generate-json    # Regenerate JSON from content (run before dev/build)
```

> `yarn dev` = `yarn generate-json && astro dev`. If an Astro process is already running, kill it first.

For CI/PR verification, the check command is: `yarn generate-json && npx astro check`

## Architecture

### Content Pipeline

`scripts/jsonGenerator.js` reads all content from `src/content/` and generates JSON config files used at build time. This **must** run before `astro dev` or `astro build` — it is automatically included in `dev`, `build`, and `ci` scripts.

### Content Structure

Blog posts live in `src/content/post/YYYY/MM/slug.md`. Each post has this frontmatter:

```yaml
title: ""
date: 2025-01-01T10:00:00.000Z
images:
  - "/images/post/YYYY/MM/image.png"
author: "Charles Luo"
description: ""
categories: ["technology"]
tags: ["tag1", "tag2"]
type: "regular"   # or "featured"
blueskyPostURI: ""
draft: false
```

The `blueskyPostURI` field is managed by the CI pipeline — leave it empty in new posts and GitHub Actions will populate it after auto-posting to Bluesky.

### OG Image Generation

- At dev time: OG images render as HTML at `/og-preview`
- At build time: `scripts/generate-og-images.js` uses Puppeteer to convert HTML → PNG
- OG image template: `src/pages/api/og/[...slug].ts`

### Automated Social Posting (GitHub Actions)

`.github/workflows/ci.yml` runs a 3-job pipeline on push to `master`:
1. **build-and-deploy**: detects new posts without `blueskyPostURI`, builds and deploys to GitHub Pages
2. **bluesky-social**: uses GitHub Models API (GPT-4.1) to generate a caption, posts to Bluesky, commits the URI back to the post frontmatter
3. **rebuild-after-bluesky**: rebuilds and redeploys with the updated frontmatter

Only one post is processed per CI run.

### Configuration Files

All site configuration lives in `src/config/`:
- `config.json` — site metadata, base URL, pagination
- `theme.json` — colors, fonts, typography
- `menu.json` — navigation links
- `social.json` — social media profile URLs

### Styling

Use Tailwind CSS utility classes. Avoid custom CSS — the project uses a custom Tailwind plugin in `src/tailwind-plugin/`.

### Infrastructure

`deploy/` contains Terraform config for an optional self-hosted Nginx server (alternative to GitHub Pages). Run via `deploy/deploy.sh` with a `.env` file containing `SERVER_IP`.

## Content Guidelines

- Place post images in `public/images/post/YYYY/MM/`
- Use descriptive filenames for posts and images
- Optimize images before adding
- Do not modify `package-lock.json` in content-only PRs
- Do not invoke Superpowers Skills till I mention it explicitly e.g. using Superpowers
