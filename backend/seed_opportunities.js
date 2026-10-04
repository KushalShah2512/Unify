const prisma = require("./src/config/database");

const opportunities = [
  {
    title: "Flutter Developer Intern",
    description:
      "Work with the mobile development team to build and maintain Flutter applications.",
    type: "INTERNSHIP",
    companyName: "ABC Technologies",
    location: "Pune, Maharashtra",
    workMode: "HYBRID",
    stipend: "₹15,000/month",
    salary: null,
    applicationUrl: "https://example.com/flutter-intern",
    requiredSkills: ["Flutter", "Dart", "Firebase", "Git"],
    preferredSkills: "REST APIs, UI/UX",
    experience: "Fresher",
    isActive: true,
  },
  {
    title: "React.js Developer Intern",
    description:
      "Build responsive web applications using React.js and modern frontend technologies.",
    type: "INTERNSHIP",
    companyName: "TechNova Solutions",
    location: "Mumbai, Maharashtra",
    workMode: "REMOTE",
    stipend: "₹12,000/month",
    salary: null,
    applicationUrl: "https://example.com/react-intern",
    requiredSkills: ["React", "JavaScript", "HTML", "CSS", "Git"],
    preferredSkills: "TypeScript, Tailwind CSS",
    experience: "Fresher",
    isActive: true,
  },
  {
    title: "Node.js Backend Developer Intern",
    description:
      "Develop REST APIs and backend services using Node.js, Express.js, and databases.",
    type: "INTERNSHIP",
    companyName: "CodeSphere Technologies",
    location: "Bangalore, Karnataka",
    workMode: "HYBRID",
    stipend: "₹18,000/month",
    salary: null,
    applicationUrl: "https://example.com/node-intern",
    requiredSkills: ["Node.js", "Express.js", "MongoDB", "REST API", "Git"],
    preferredSkills: "Docker, PostgreSQL",
    experience: "Fresher",
    isActive: true,
  },
];

async function main() {
  await prisma.opportunity.createMany({
    data: opportunities,
  });

  console.log("Test opportunities created successfully.");
}

main()
  .catch((error) => {
    console.error("Error creating opportunities:", error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });