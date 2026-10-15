# shaunchopra.com.au

My personal portfolio site: projects, AWS certifications, skills, education and contact links.

Live at **https://www.shaunchopra.com.au**

## Stack

- Plain HTML, CSS and JavaScript (no framework, no build step)
- Hosted on AWS: S3 (private bucket) behind CloudFront with Origin Access Control
- HTTPS via an ACM certificate, DNS in Route 53

## Structure

```
index.html        page structure
css/styles.css    all styling, light and dark theme
js/main.js        small script (footer year)
images/           photo, project screenshots, badges, icons
```

## Run locally

Open `index.html` in a browser. No install needed.

## Deploy

```bash
aws s3 sync . s3://<bucket-name> --exclude ".git/*" --exclude "README.md" --exclude ".gitignore" --delete
aws cloudfront create-invalidation --distribution-id <distribution-id> --paths "/*"
```
