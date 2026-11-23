import type { ImageMetadata } from 'astro';
import saa from '../assets/aws-saa.png';
import aif from '../assets/aws-aif.png';
import ccp from '../assets/aws-ccp.png';

export interface Cert {
  /** Short name shown on the page */
  name: string;
  /** Full official title, used for alt text and structured data */
  fullName: string;
  level: 'Associate' | 'Foundational';
  badge: ImageMetadata;
  alt: string;
}

export const issuer = { name: 'Amazon Web Services', url: 'https://aws.amazon.com' } as const;

export const certs: Cert[] = [
  {
    name: 'Solutions Architect',
    fullName: 'AWS Certified Solutions Architect – Associate',
    level: 'Associate',
    badge: saa,
    alt: 'AWS Certified Solutions Architect – Associate badge',
  },
  {
    name: 'AI Practitioner',
    fullName: 'AWS Certified AI Practitioner',
    level: 'Foundational',
    badge: aif,
    alt: 'AWS Certified AI Practitioner badge',
  },
  {
    name: 'Cloud Practitioner',
    fullName: 'AWS Certified Cloud Practitioner',
    level: 'Foundational',
    badge: ccp,
    alt: 'AWS Certified Cloud Practitioner badge',
  },
];
