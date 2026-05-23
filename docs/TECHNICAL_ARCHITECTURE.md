# Technical Architecture - RestaurantAI

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND (React/Next.js)                  │
│  Dashboard | Menu Management | Reports | AI Recommendations │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS / REST API / GraphQL
┌──────────────────────┴──────────────────────────────────────┐
│                    API GATEWAY (Express)                     │
│  Auth | Rate Limiting | Validation | CORS | Logging         │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼────┐  ┌─────▼────┐  ┌─────▼────┐
│  Business  │  │    AI    │  │Integration│
│   Logic    │  │  Engine  │  │   Layer   │
│ Controllers│  │(LangChain)│ │(Square,   │
│ Services   │  │ Agents   │  │Toast, etc)│
└───────┬────┘  └─────┬────┘  └─────┬────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
┌──────────────────────┴──────────────────────────────────────┐
│              DATA LAYER (PostgreSQL + Redis)                 │
│  Restaurants | Users | Menu | Sales | Expenses | Analytics  │
│  AI Logs | Recommendations | Integrations                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    ┌───▼──┐       ┌────▼────┐   ┌──▼─────┐
    │ AWS  │       │ OpenAI  │   │ Stripe │
    │ S3   │       │ API     │   │ API    │
    │      │       │ (GPT-4) │   │        │
    └──────┘       └─────────┘   └────────┘
```

## Tech Stack Details

### Backend

**Runtime & Framework:**
- Node.js 18+ (LTS)
- Express.js 4.18+
- TypeScript (for type safety)

**Database:**
- PostgreSQL 12+
  - Primary OLTP (transactional) database
  - Multi-tenant schema
  - Time-series data for analytics
- Redis 6+
  - Session management
  - Rate limiting
  - Real-time cache
  - Job queue (Bull)

**AI & ML:**
- OpenAI API (GPT-4 Turbo)
- LangChain (agent orchestration)
- Vector embeddings (for semantic search)
- Custom fine-tuning on restaurant domain data

**Authentication & Security:**
- JWT (JSON Web Tokens)
- bcrypt (password hashing)
- Auth0 (optional SSO)
- SSL/TLS for all endpoints
- CORS protection

**External Services:**
- Stripe (payments & subscriptions)
- SendGrid (emails)
- AWS S3 (document storage)
- AWS RDS (managed PostgreSQL)
- AWS Lambda (scheduled jobs)
- Slack API (notifications)

### Frontend

**Framework & Build:**
- React 18+
- Next.js 13+ (SSR, static generation)
- TypeScript
- Vite (fast build tool alternative)

**UI Components & Styling:**
- Shadcn UI (headless components)
- Tailwind CSS 3+
- Radix UI (primitives)
- Framer Motion (animations)

**Data & State Management:**
- TanStack Query (React Query) - server state
- Zustand or Jotai - client state
- React Hook Form - form management
- Zod - schema validation

**Visualization:**
- Recharts (financial charts)
- Chart.js (alternative)
- Apache ECharts (complex dashboards)

**Testing:**
- Jest - unit tests
- React Testing Library - component tests
- Cypress - E2E tests
- Playwright - browser automation

### DevOps & Deployment

**Version Control:**
- Git + GitHub
- Main, develop, feature branches
- Branch protection rules

**CI/CD Pipeline:**
- GitHub Actions
  - Run tests on PR
  - Lint code
  - Type checking
  - Build Docker images
  - Deploy to staging/production

**Containerization:**
- Docker & Docker Compose (local development)
- Kubernetes (future scaling)

**Hosting:**
- AWS EC2 (backend)
- AWS RDS (database)
- AWS S3 (static assets)
- CloudFront CDN (global distribution)
- Vercel or Netlify (frontend alternative)

**Monitoring & Logging:**
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Datadog (APM & monitoring)
- Sentry (error tracking)
- CloudWatch (AWS logs)

## Multi-Tenant Architecture

```
Row-Level Security (RLS) in PostgreSQL:

Using policies to isolate data per restaurant
- Row identifier: restaurant_id
- Each table has restaurant_id FK
- RLS policies enforce: current_user_id -> restaurant_id
```

## API Architecture

### RESTful Endpoints

```
GET    /api/v1/restaurants
GET    /api/v1/restaurants/{id}
POST   /api/v1/restaurants
PATCH  /api/v1/restaurants/{id}

GET    /api/v1/restaurants/{id}/menu-items
POST   /api/v1/restaurants/{id}/menu-items
PATCH  /api/v1/restaurants/{id}/menu-items/{item_id}

GET    /api/v1/restaurants/{id}/sales
POST   /api/v1/restaurants/{id}/sales

GET    /api/v1/restaurants/{id}/dashboard
GET    /api/v1/restaurants/{id}/reports/profitability

POST   /api/v1/restaurants/{id}/ai/analyze
GET    /api/v1/restaurants/{id}/recommendations
POST   /api/v1/restaurants/{id}/recommendations/{rec_id}/execute
```

### AI Integration Points

**Menu Analyzer Agent:**
- Input: Sales data + costs for 30 days
- Output: Top/bottom performers, recommendations
- Trigger: Daily 2 AM, or on-demand

**Price Optimizer Agent:**
- Input: Elasticity data, competition pricing
- Output: Recommended price adjustments
- Trigger: Weekly

**Inventory Predictor Agent:**
- Input: Historical usage + upcoming reservations
- Output: Predicted stock needs
- Trigger: Daily

**Demand Forecaster Agent:**
- Input: Historical sales + events/weather/calendar
- Output: Predicted busy times
- Trigger: Daily

## Data Flow

### Sales Entry (from POS)

```
1. POS System (Square/Toast) → Webhook
2. Webhook Receiver → Validates & transforms
3. Database → Insert into sales + sale_items
4. Event Queue → Trigger AI analysis if needed
5. Real-time Update → Push to frontend via WebSocket
6. Daily Summary → Calculate metrics at 1 AM
```

### AI Recommendation Flow

```
1. User/System triggers: /api/restaurants/{id}/ai/analyze
2. Controller → AI Service
3. AI Service → Fetch restaurant data
4. LangChain Agent → Process with GPT-4
5. Generate recommendations → Save to DB
6. Return to frontend → User sees options
7. User accepts/rejects → Status updated
8. Auto-execute if enabled → Apply changes
```

## Security Considerations

### Authentication
- JWT stored in httpOnly cookie (XSS protection)
- Refresh tokens (15 min access, 7 day refresh)
- MFA optional for business users

### Authorization
- Role-based access control (RBAC)
- Roles: owner, manager, chef, waiter, analyst
- Row-level security via PostgreSQL policies

### Data Protection
- Encryption at rest (AWS KMS)
- Encryption in transit (TLS 1.3)
- PCI-DSS compliance for payments
- GDPR compliance for EU users
- Regular security audits

### API Security
- Rate limiting (100 req/min per IP)
- Input validation & sanitization
- SQL injection prevention (parameterized queries)
- CSRF protection (SameSite cookies)
- API versioning for backward compatibility

## Performance Optimization

### Database
- Indexing on frequently queried columns
- Partitioning large tables by date
- Query optimization & explain plans
- Connection pooling (PgBouncer)

### Caching
- Redis cache for user sessions
- Cache dashboard data (1-hour TTL)
- Cache menu items & ingredients

### Frontend
- Code splitting by route
- Image optimization (WebP)
- Lazy loading for charts
- Virtualization for long lists

### API
- Pagination (default 20, max 100)
- Field selection/sparse fieldsets
- HTTP caching headers
- Gzip compression

## Scalability Plan

**Phase 1 (MVP):** Single EC2 instance + RDS

**Phase 2 (100+ customers):** 
- Load balancer (ELB)
- Multiple EC2 instances (auto-scaling)
- Read replicas for RDS
- Redis cluster

**Phase 3 (1000+ customers):**
- Kubernetes (EKS)
- Database sharding (by restaurant_id)
- Microservices (AI agents as separate services)
- Message queue (RabbitMQ/Kafka) for async jobs

## Disaster Recovery

- Database backups: Daily + point-in-time recovery
- Geo-redundancy: Multi-AZ deployment
- Failover: Automatic via RDS Multi-AZ
- Data retention: 7-year archive (compliance)
