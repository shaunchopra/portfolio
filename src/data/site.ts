// Who the site is about, and the copy that is not tied to one section.

export const site = {
  url: 'https://www.shaunchopra.com',
  name: 'Shaun Chopra',
  givenName: 'Shaun',
  familyName: 'Chopra',
  lang: 'en-AU',
  locale: 'en_AU',

  title: 'Shaun Chopra · RMIT Computer Science student, AWS certified',
  description:
    'Shaun Chopra, Computer Science student at RMIT with three AWS certifications. Projects, certifications and contact.',
  ogImage: {
    path: '/og.png',
    width: 1200,
    height: 630,
    alt: 'Shaun Chopra, Computer Science student at RMIT University with three AWS certifications',
  },

  jobTitle: 'Computer Science student',
  university: { name: 'RMIT University', url: 'https://www.rmit.edu.au' },
  lead: 'Computer Science student at RMIT and AWS Certified Solutions Architect. I build websites and cloud projects, and I like shipping things people actually use.',
  seeking: 'A summer internship',
  contactLead: "I'm looking for a summer internship or any chance to learn from an experienced team.",

  email: 'shaunchopra08@gmail.com',
  emailSubject: 'Hi Shaun',
  linkedin: 'https://www.linkedin.com/in/shaun-chopra-77040b3b6/',
  github: 'https://github.com/shaunchopra',
  source: 'https://github.com/shaunchopra/portfolio',

  theme: { light: '#f4f0e6', dark: '#1a1814' },
} as const;

export const mailto = `mailto:${site.email}?subject=${encodeURIComponent(site.emailSubject)}`;

// Numbered sections, in page order. The header nav and the "01 / ..." labels both read this.
export const sections = [
  { id: 'route', nav: 'Route', label: 'Request trace' },
  { id: 'certs', nav: 'Certifications', label: 'Credentials' },
  { id: 'projects', nav: 'Projects', label: 'Work' },
  { id: 'skills', nav: 'Skills', label: 'Toolkit' },
  { id: 'education', nav: 'Education', label: 'Study' },
  { id: 'contact', nav: 'Contact', label: 'Contact' },
] as const;

export type SectionId = (typeof sections)[number]['id'];

export function sectionMeta(id: SectionId) {
  const i = sections.findIndex((s) => s.id === id);
  return { ...sections[i]!, index: String(i + 1).padStart(2, '0') };
}
