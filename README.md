# RestaurantAI 🤖

**AI-Powered Restaurant Management System**

*Automate financial decisions, optimize menu profitability, and let AI manage your restaurant's growth.*

## What is RestaurantAI?

RestaurantAI is a SaaS platform that uses LLM-powered AI agents to autonomously analyze and optimize restaurant operations. Instead of just providing reports, our AI takes action:

✅ **Real-time Profitability Analysis** - Know exactly which dishes make money  
✅ **Autonomous Price Optimization** - AI adjusts prices based on demand & margins  
✅ **Inventory Prediction** - Reduce waste by forecasting ingredient usage  
✅ **Demand Forecasting** - Predict busy times and optimize staffing  
✅ **Automated Recommendations** - Act on insights without manual intervention  
✅ **Multi-Location Dashboard** - Manage all locations from one place  
✅ **POS Integration** - Works with Square, Toast, TouchBistro, and more  

## The Problem We Solve

**Current state of restaurant management:**
- Toast, Square: Great for POS but no IA intelligence
- MarginEdge: Analyzes costs but requires manual decisions ($300-900/mo)
- 7Shifts: Manages labor but ignores profitability
- Most restaurants: Use Excel and guesswork

**The gap:** No tool exists that combines financial analysis WITH autonomous AI execution.

## Why RestaurantAI?

| Feature | Toast | Square | MarginEdge | RestaurantAI |
|---------|-------|--------|-----------|---------------|
| POS | ✅ | ✅ | ❌ | Integrates |
| Financial Analysis | ✅ Basic | ✅ Basic | ✅✅ Deep | ✅✅✅ Deeper |
| AI Automation | ❌ | ❌ | ❌ | ✅✅✅ **CORE** |
| Rental/Subscription | $65-400 | $0-299 | $300-900 | **$99-999** |
| Setup Time | 2-4 wks | 1 wk | 4-6 wks | **< 24 hrs** |

## Competitive Advantages

1. **80% cheaper than MarginEdge** - $99/mo vs $300-900
2. **IA that executes** - Not just reports, actual automated decisions
3. **Simpler to use** - Built for managers, not data scientists
4. **Faster ROI** - See 3-5% margin improvement in 30 days
5. **Multi-location from day 1** - Scales with your business

## Business Model

### Pricing

- **Starter** - $99/mo (1 restaurant, core features)
- **Pro** - $299/mo (up to 5 locations, advanced AI)
- **Enterprise** - $999+/mo (unlimited, dedicated support, custom integrations)

### Projected ROI

- Break-even: 15-20 customers (5-6 months)
- Average customer saves: **$30K/year** (6% margin improvement on $50K avg revenue)
- Net customer value: **$10K+ annual profit per customer**
- LTV:CAC ratio: 10:1+ (excellent)

## Tech Stack

- **Backend**: Node.js (Express) + PostgreSQL
- **Frontend**: React (Next.js) + ShadcnUI + Tailwind
- **AI**: OpenAI API (GPT-4) + LangChain
- **Hosting**: AWS (RDS, EC2, S3)
- **Auth**: JWT + Auth0
- **Payments**: Stripe

## Quick Start (Development)

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- Docker (optional)
- OpenAI API key
- Stripe API key

### Setup

```bash
# Clone repo
git clone https://github.com/danielon17/restaurantai.git
cd restaurantai

# Backend setup
cd backend
npm install
cp .env.example .env
# Add your keys to .env
npm run migrate
npm run seed
npm run dev

# Frontend setup (new terminal)
cd frontend
npm install
npm run dev
```

Visit `http://localhost:3000`

## Project Roadmap

### MVP (8-12 weeks) - Q2 2026
- [x] Plan & Research
- [ ] Database Schema
- [ ] Authentication
- [ ] Dashboard (Revenue, Expenses, Margins)
- [ ] Menu Profitability Analysis
- [ ] Inventory Management (Basic)
- [ ] First AI Agent (Menu Analysis)
- [ ] POS Integration (Webhooks)
- [ ] Beta Testing (3-5 restaurants)

### V1.0 (Month 4-5)
- [ ] Advanced AI Agents (Price Optimization, Demand Forecasting)
- [ ] Multi-location Management
- [ ] Advanced Reporting (PDF, Excel export)
- [ ] Mobile App (Read-only)

### Scaling (Month 6+)
- [ ] Direct POS Integration (Square, Toast APIs)
- [ ] Marketplace (Third-party integrations)
- [ ] Enterprise Sales
- [ ] International Expansion

## Documentation

- [Architecture & Database Schema](./docs/TECHNICAL_ARCHITECTURE.md)
- [API Specification](./docs/API_SPEC.yaml)
- [Database Schema SQL](./docs/DATABASE_SCHEMA.sql)
- [Competitive Analysis](./docs/COMPETITIVE_ANALYSIS.md)
- [Setup & Deployment](./docs/SETUP.md)
- [Contributing Guidelines](./CONTRIBUTING.md)

## Current Status

**Phase:** Planning & Design ✅

**Next:** Backend + Frontend Infrastructure

## Contact

- Website: [restaurantai.com](#) (coming soon)
- Email: support@restaurantai.com
- Discord: [Join our community](#)

## License

Proprietary - All rights reserved

---

**Made with ❤️ for restaurant owners who want to focus on great food, not spreadsheets.**
