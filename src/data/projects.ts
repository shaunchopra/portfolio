import type { ImageMetadata } from 'astro';
import oj from '../assets/oj.jpg';
import kova from '../assets/kova.jpg';

/** A project with a screenshot and a write-up */
export interface FeaturedProject {
  name: string;
  /** Small label above the title, e.g. how the work came about */
  kicker: string;
  summary: string;
  stack: string;
  url: string;
  /** Visible link text, e.g. "Visit example.com" */
  linkText: string;
  image: ImageMetadata;
  alt: string;
}

/** A one-line entry in the "More projects" list */
export interface Project {
  name: string;
  summary: string;
  meta: string;
}

export const featured: FeaturedProject[] = [
  {
    name: 'OJ Auto Detailing',
    kicker: 'Paid freelance',
    summary:
      'Website for a Melbourne car detailing business, with package pricing and a quote form that goes straight to the owner. Paid freelance work, live since June 2026. I also stood up my own DynamoDB table so every quote request is saved as a record.',
    stack: 'Astro, Node.js, AWS Lambda, S3, CloudFront and DynamoDB',
    url: 'https://www.oj-auto-detailing.com.au',
    linkText: 'Visit oj-auto-detailing.com.au',
    image: oj,
    alt: 'OJ Auto Detailing website, recent work section',
  },
  {
    name: 'Kova Consulting',
    kicker: 'Co-founded',
    summary:
      'Website for a web services business I co-founded, aimed at Melbourne trade businesses. I built the site, an Express backend and the contact form.',
    stack: 'JavaScript, Node.js, Express, EC2, SES and Route 53',
    url: 'https://www.kovaconsultancy.com.au',
    linkText: 'Visit kovaconsultancy.com.au',
    image: kova,
    alt: 'Kova Consulting website homepage',
  },
];

export const more: Project[] = [
  {
    name: 'Minecraft village generator',
    summary: "A C++ program that builds a village in a live Minecraft world. I'm writing the plot finding and house building.",
    meta: 'C++, uni team project',
  },
  {
    name: 'Scheduled greeting emails',
    summary: 'EventBridge Scheduler triggers a Node.js Lambda that sends morning, afternoon and night emails through SES.',
    meta: 'AWS, personal',
  },
  {
    name: 'LC-3 assembly in Minecraft',
    summary: 'Assembly programs that build staircases and reverse rows of blocks in Minecraft.',
    meta: 'Assembly, uni',
  },
  {
    name: 'Victorian road crash explorer',
    summary: 'A web app over Victorian road crash data, built with a teammate.',
    meta: 'Java and SQLite, uni',
  },
];
