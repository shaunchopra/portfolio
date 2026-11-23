// Post-build SEO assertions for the static Astro output.
// Usage: node .github/scripts/check-seo.mjs [dist-dir]
import { existsSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const dist = process.argv[2] ?? "dist";
const errors = [];
const fail = (msg) => errors.push(msg);

const required = [
  "index.html",
  "404.html",
  "robots.txt",
  "sitemap-index.xml",
  "sitemap-0.xml",
  "og.png",
  "site.webmanifest",
];
for (const f of required) {
  const p = join(dist, f);
  if (!existsSync(p)) fail(`missing ${p}`);
  else if (statSync(p).size === 0) fail(`empty ${p}`);
}

const indexPath = join(dist, "index.html");
if (existsSync(indexPath)) {
  const html = readFileSync(indexPath, "utf8");

  const canonical = [...html.matchAll(/<link\b[^>]*>/gi)]
    .map((m) => m[0])
    .find((tag) => /\brel\s*=\s*["']?canonical["'\s>]/i.test(tag));
  const href = canonical?.match(/\bhref\s*=\s*["']?([^"'\s>]+)/i)?.[1];
  if (!href) fail("index.html: no <link rel=\"canonical\" href=...>");
  else if (!/^https:\/\//.test(href)) fail(`index.html: canonical is not absolute https: ${href}`);
  else console.log(`canonical: ${href}`);

  const blocks = [
    ...html.matchAll(/<script\b[^>]*type\s*=\s*["']?application\/ld\+json["']?[^>]*>([\s\S]*?)<\/script>/gi),
  ];
  if (blocks.length === 0) fail("index.html: no JSON-LD <script type=\"application/ld+json\">");
  blocks.forEach((m, i) => {
    try {
      const data = JSON.parse(m[1]);
      const items = Array.isArray(data) ? data : data["@graph"] ?? [data];
      const types = items.map((d) => d?.["@type"]).filter(Boolean);
      if (!(data["@context"] ?? items[0]?.["@context"])) fail(`JSON-LD #${i + 1}: missing @context`);
      console.log(`JSON-LD #${i + 1}: ok (${types.join(", ") || "no @type"})`);
    } catch (e) {
      fail(`JSON-LD #${i + 1}: invalid JSON (${e.message})`);
    }
  });
}

const robots = join(dist, "robots.txt");
if (existsSync(robots) && !/sitemap:\s*https:\/\//i.test(readFileSync(robots, "utf8"))) {
  console.log("::warning file=robots.txt::robots.txt has no absolute Sitemap: line");
}

if (errors.length) {
  for (const e of errors) console.log(`::error::${e}`);
  process.exit(1);
}
console.log("SEO checks passed.");
