export interface SkillGroup {
  group: string;
  items: string[];
}

export const skills: SkillGroup[] = [
  { group: 'Languages', items: ['JavaScript', 'Java', 'C++', 'SQL', 'HTML', 'CSS'] },
  { group: 'Web', items: ['Node.js', 'Express', 'React', 'Astro', 'PostgreSQL', 'SQLite'] },
  { group: 'AWS', items: ['Lambda', 'API Gateway', 'S3', 'CloudFront', 'EC2', 'DynamoDB', 'SES', 'Route 53'] },
  { group: 'Tools', items: ['Git', 'GitHub', 'VS Code'] },
];
