# shaunchopra.com

My personal portfolio site: projects, AWS certifications, skills, education and contact links.

Live at **https://www.shaunchopra.com**

## Stack

- [Astro](https://astro.build) static site, no client framework. The only client JS is the
  request-trace panel, which measures the real page load on the live domain.
- Hosted on AWS: private S3 bucket behind CloudFront (Origin Access Control), ACM certificate,
  Route 53 DNS. A CloudFront Function redirects the apex to `www` and maps directory URLs.
- All infrastructure is managed with Terraform in [`terraform/`](terraform/README.md).
- CI/CD with GitHub Actions, authenticating to AWS through OIDC (no stored keys).

## Structure

```
src/data/         content: profile, certs, projects, skills, education (edit these)
src/components/   page sections (Hero, Trace, Projects, …) and the SEO head
src/layouts/      base HTML layout
src/pages/        index and 404
src/styles/       design tokens and base styles
src/assets/       images, optimised at build time (AVIF/WebP)
public/           fonts, favicons, robots.txt, OG image, web manifest
terraform/        S3, CloudFront, ACM, Route 53, GitHub OIDC deploy role
.github/          CI and deploy workflows
```

Adding a project is one object in `src/data/projects.ts`.

## Develop

Requires Node 22.23.4 or newer (`nvm install 22`).

```bash
npm install
npm run dev       # local dev server
npm run check     # type and template checks
npm run build     # static output in dist/
npm run preview   # serve dist/
```

## CI/CD

- **CI** (`.github/workflows/ci.yml`, every PR and push): `astro check`, build, HTML validation,
  internal link check, SEO checks (canonical, JSON-LD, sitemap, robots, OG image). PRs that touch
  `terraform/` also get `terraform fmt`, `validate` and a read-only `plan` in the job summary.
- **Deploy** (`.github/workflows/deploy.yml`, push to `main`): build, upload to S3 with per-type
  cache headers (hashed `_astro/` assets immutable, HTML always revalidated, HTML uploaded last),
  invalidate CloudFront, prune old files, then smoke-test the live site.

Infrastructure changes are applied locally with `terraform apply`. CI only plans.
