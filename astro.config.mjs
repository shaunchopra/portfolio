// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// Static output only: `astro build` writes plain files to dist/ for S3 + CloudFront.
export default defineConfig({
  site: 'https://www.shaunchopra.com',
  trailingSlash: 'ignore',
  build: {
    format: 'directory',
  },
  integrations: [
    sitemap({
      filter: (page) => !/\/404\/?$/.test(new URL(page).pathname),
    }),
  ],
});
