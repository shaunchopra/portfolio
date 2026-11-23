export interface Study {
  school: string;
  /** The qualification on its own, e.g. for the hero summary */
  qualification: string;
  /** Full description shown in the Education section */
  detail: string;
  /** Shown as written, e.g. "2026 – present" */
  years: string;
  /** Still enrolled (used for structured data: affiliation vs alumniOf) */
  current: boolean;
}

export const education: Study[] = [
  {
    school: 'RMIT University',
    qualification: 'Bachelor of Computer Science (Professional)',
    detail:
      'Bachelor of Computer Science (Professional). Completed Java Programming Bootcamp, Java Programming Studio and C++ Programming Bootcamp. Currently taking C++ Programming Studio and Maths for Computing.',
    years: '2026 – present',
    current: true,
  },
  {
    school: 'Mernda Central College',
    qualification: 'Victorian Certificate of Education (VCE)',
    detail: 'Victorian Certificate of Education (VCE)',
    years: '2020 – 2025',
    current: false,
  },
];
