# Setup & Deployment Guide - RestaurantAI

## Local Development Setup

### Prerequisites

- Node.js 18.0.0+ ([download](https://nodejs.org/))
- PostgreSQL 12+ ([download](https://www.postgresql.org/download/))
- Git
- Redis 6+ (optional, for local caching)
- Docker & Docker Compose (optional)

### 1. Clone Repository

```bash
git clone https://github.com/danielon17/restaurantai.git
cd restaurantai
```

### 2. Backend Setup

```bash
cd backend
npm install

# Copy environment template
cp .env.example .env

# Edit .env with your settings
# Required variables:
# - DATABASE_URL=postgresql://user:password@localhost:5432/restaurantai
# - JWT_SECRET=your_jwt_secret_here
# - OPENAI_API_KEY=sk-...
# - STRIPE_SECRET_KEY=sk_test_...

# Run database migrations
npm run migrate

# Seed initial data (optional)
npm run seed

# Start development server
npm run dev
```

Server runs on `http://localhost:3001`

### 3. Frontend Setup

```bash
cd frontend
npm install

# Copy environment template
cp .env.example .env.local

# Edit .env.local
# NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
# NEXT_PUBLIC_STRIPE_KEY=pk_test_...

# Start development server
npm run dev
```

App runs on `http://localhost:3000`

### 4. Database Setup

```bash
# Create database
creatdb restaurantai

# Run migrations
cd backend
psql restaurantai < docs/DATABASE_SCHEMA.sql

# Verify tables
psql restaurantai
restuarantai=# \dt  -- List tables
```

## Docker Setup (Alternative)

### Using Docker Compose

```bash
# Start all services
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Testing

### Backend Tests

```bash
cd backend

# Run all tests
npm run test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

### Frontend Tests

```bash
cd frontend

# Run tests
npm run test

# E2E tests with Cypress
npm run test:e2e
```

## Production Deployment

### Option 1: AWS (Recommended)

#### 1. RDS Setup

```bash
# Create RDS PostgreSQL instance
aws rds create-db-instance \
  --db-instance-identifier restaurantai-prod \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YOUR_SECURE_PASSWORD \
  --allocated-storage 20
```

#### 2. Elastic Beanstalk (Backend)

```bash
# Initialize EB
eb init -p node.js-18 restaurantai-backend

# Create environment
eb create restaurantai-prod-env

# Deploy
eb deploy
```

#### 3. Vercel (Frontend)

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
cd frontend
vercel
```

#### 4. Environment Variables (AWS Secrets Manager)

```bash
aws secretsmanager create-secret \
  --name restaurantai/prod \
  --secret-string file://secrets.json
```

### Option 2: Docker on Any Cloud

#### Build Images

```bash
# Backend
docker build -t restaurantai-api:latest ./backend

# Frontend
docker build -t restaurantai-web:latest ./frontend
```

#### Push to Registry

```bash
# AWS ECR
aws ecr create-repository --repository-name restaurantai-api
aws ecr create-repository --repository-name restaurantai-web

AWS_ACCOUNT_ID=123456789
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker tag restaurantai-api:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/restaurantai-api:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/restaurantai-api:latest
```

### Option 3: DigitalOcean App Platform

```bash
# Connect GitHub repo
doctl apps create --spec app.yaml

# View deployment
doctl apps get restaurantai
```

## CI/CD Pipeline (GitHub Actions)

Automatically runs on every push to main:

1. **Lint** - ESLint + Prettier
2. **Type Check** - TypeScript compiler
3. **Test** - Jest + React Testing Library
4. **Build** - Compile frontend + backend
5. **Deploy** - Push to staging/production

See `.github/workflows/` for config.

## Monitoring & Logging

### Application Monitoring

```bash
# Install Datadog agent
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=<key> bash -c \
  "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_mac_os.sh)"

# Or use CloudWatch in AWS
```

### Database Monitoring

```bash
# RDS Performance Insights
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier-arn arn:aws:rds:...
```

### Error Tracking

```bash
# Sentry configuration
import sentry_sdk
sentry_sdk.init("https://<key>@sentry.io/<project>")
```

## Backup & Recovery

### Database Backups

```bash
# Manual backup
pg_dump restaurantai > backup_$(date +%Y%m%d).sql

# AWS RDS automated backups (7 days retention)
aws rds modify-db-instance \
  --db-instance-identifier restaurantai-prod \
  --backup-retention-period 7

# Restore from backup
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier restaurantai-restored \
  --db-snapshot-identifier <snapshot-id>
```

### Code Deployment Rollback

```bash
# Beanstalk
eb deploy --version <previous-version>

# Vercel
vercel --prod --prebuilt
```

## Troubleshooting

### Common Issues

**Database connection refused**
```bash
# Check PostgreSQL is running
psql --version
sudo systemctl status postgresql

# Verify connection string
echo $DATABASE_URL
```

**API not connecting to frontend**
```bash
# Check CORS headers
curl -H "Origin: http://localhost:3000" http://localhost:3001/health

# Verify NEXT_PUBLIC_API_URL in frontend
```

**OpenAI API errors**
```bash
# Verify key
echo $OPENAI_API_KEY

# Test API
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

## Performance Tuning

### Database Optimization

```sql
-- Analyze query performance
EXPLAIN ANALYZE SELECT * FROM sales WHERE sale_date > NOW() - INTERVAL '30 days';

-- Create indexes
CREATE INDEX idx_sales_date ON sales(sale_date DESC);
CREATE INDEX idx_menu_performance ON menu_performance(restaurant_id, performance_date DESC);
```

### Frontend Optimization

```bash
# Build analysis
cd frontend
npm run build -- --analyze

# Check bundle size
npm run build -- --analyze
```

## Security Hardening

```bash
# Update dependencies
npm audit fix

# Run security scan
npm audit

# Check for secrets in code
git-secrets --install
git-secrets --register-aws
```

## Support

For issues, create a GitHub issue or email support@restaurantai.com
