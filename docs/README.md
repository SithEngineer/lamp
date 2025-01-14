# Development Documentation

This directory contains decision logs, architecture documentation, and contribution guidelines for the Lamp project.

## Structure

- **`decision-logs/`**: Feature planning documents and architectural decisions
  - Use format: `YYYY-MM-DD-feature-name.md`
  - Created before implementation begins
- **`ARCHITECTURE.md`**: High-level system design and component relationships
- **`CONTRIBUTING.md`**: Developer guidelines and workflow
- **`TESTING.md`**: Testing strategy and best practices
- **`CI_CD.md`**: Pipeline configuration and deployment process

## Development Workflow

1. **Feature Discussion** → Create decision log
2. **Design & Planning** → Update ARCHITECTURE.md if needed
3. **Test-First Development** → Write tests before code
4. **Code Review** → Ensure adherence to guidelines in CONTRIBUTING.md
5. **Merge & Deploy** → Automated via CI/CD pipeline

See CONTRIBUTING.md for detailed workflow instructions.
