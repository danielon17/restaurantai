# Contributing to RestaurantAI

## Getting Started

1. Read the [Technical Architecture](./docs/TECHNICAL_ARCHITECTURE.md)
2. Follow the [Setup Guide](./docs/SETUP.md)
3. Check the [API Specification](./docs/API_SPEC.yaml)

## Development Workflow

### Create a Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### Code Style
- Use TypeScript for type safety
- Follow ESLint + Prettier rules
- Write tests alongside code
- Document your changes

### Commit Messages
```
feat: Add menu item creation endpoint
fix: Correct COGS calculation
docs: Update API docs
test: Add tests for profitability agent
```

### Pull Request Process
1. Create PR against `develop` (not `main`)
2. Include tests (>80% coverage)
3. Add description of changes
4. Request code review
5. Pass CI/CD checks
6. Merge when approved

## Testing Requirements

### Backend
```bash
npm run test          # Unit tests
npm run test:coverage # Coverage report
npm run lint          # ESLint
```

### Frontend
```bash
npm run test          # Jest tests
npm run test:e2e      # Cypress E2E
npm run lint          # ESLint
```

All PRs must have:
- ✅ Unit tests
- ✅ >80% coverage
- ✅ ESLint passing
- ✅ No console errors

## Database Changes

For any schema changes:
1. Create migration file: `migrations/001_add_new_table.sql`
2. Test locally
3. Add rollback script
4. Document in PR

## Deployment

### Staging (develop branch)
- Auto-deploys to staging on push
- Test at https://staging.restaurantai.com

### Production (main branch)
- Manual approval required
- Must pass all tests + staging verification
- Automatic deployment after merge

## Questions?

- Check the docs in `/docs`
- Create a GitHub Issue
- Ask in discussions

---

**Happy coding! 🚀**
