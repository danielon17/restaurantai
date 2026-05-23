-- RestaurantAI Database Schema (PostgreSQL 12+)
-- Multi-tenant architecture with Row-Level Security

-- ============================================
-- 1. CORE ENTITIES
-- ============================================

CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    industry VARCHAR(50),
    status VARCHAR(50) DEFAULT 'active',
    
    monthly_revenue_avg DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    stripe_customer_id VARCHAR(255) UNIQUE,
    subscription_tier VARCHAR(50) DEFAULT 'starter',
    subscription_status VARCHAR(50) DEFAULT 'trial',
    trial_ends_at TIMESTAMP,
    
    settings JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    phone VARCHAR(20),
    
    pos_system VARCHAR(50),
    pos_location_id VARCHAR(255),
    
    status VARCHAR(50) DEFAULT 'active',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    
    status VARCHAR(50) DEFAULT 'active',
    email_verified_at TIMESTAMP,
    last_login_at TIMESTAMP,
    
    preferences JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE user_restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    
    role VARCHAR(50) NOT NULL,
    permissions JSONB DEFAULT '{}'::jsonb,
    
    invited_at TIMESTAMP,
    accepted_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active',
    
    UNIQUE(user_id, restaurant_id, location_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. MENU & INVENTORY
-- ============================================

CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    
    base_price DECIMAL(8,2) NOT NULL,
    cost_of_goods DECIMAL(8,2),
    margin_percent DECIMAL(5,2),
    
    status VARCHAR(50) DEFAULT 'active',
    available BOOLEAN DEFAULT TRUE,
    
    image_url TEXT,
    tags JSONB DEFAULT '[]'::jsonb,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    
    current_quantity DECIMAL(12,3),
    unit VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(8,2),
    
    reorder_level DECIMAL(12,3),
    reorder_quantity DECIMAL(12,3),
    
    status VARCHAR(50) DEFAULT 'active',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recipe_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
    
    quantity DECIMAL(10,3) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    unit_cost DECIMAL(8,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. TRANSACTIONS
-- ============================================

CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    
    order_number VARCHAR(100),
    external_order_id VARCHAR(255),
    
    sale_date DATE NOT NULL,
    sale_time TIME NOT NULL,
    
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0,
    discount DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    
    payment_method VARCHAR(50),
    customer_count INT,
    
    status VARCHAR(50) DEFAULT 'completed',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_restaurant_date (restaurant_id, sale_date),
    INDEX idx_location_date (location_id, sale_date)
);

CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
    
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(8,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    
    menu_item_name VARCHAR(255),
    menu_item_category VARCHAR(100),
    cogs_snapshot DECIMAL(8,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    
    description VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    
    expense_date DATE NOT NULL,
    payment_date DATE,
    payment_method VARCHAR(50),
    
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    receipt_url TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_restaurant_date (restaurant_id, expense_date),
    INDEX idx_category (restaurant_id, category)
);

-- ============================================
-- 4. AI & RECOMMENDATIONS
-- ============================================

CREATE TABLE ai_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    
    agent_type VARCHAR(100) NOT NULL,
    
    input_data JSONB NOT NULL,
    output_data JSONB NOT NULL,
    
    status VARCHAR(50) DEFAULT 'completed',
    error_message TEXT,
    
    model_used VARCHAR(100),
    tokens_used INT,
    duration_ms INT,
    
    run_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
    ai_run_id UUID REFERENCES ai_runs(id) ON DELETE SET NULL,
    
    recommendation_type VARCHAR(100) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    confidence_score DECIMAL(3,2),
    
    target_id UUID,
    target_type VARCHAR(50),
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    action_json JSONB,
    
    status VARCHAR(50) DEFAULT 'pending',
    accepted_at TIMESTAMP,
    executed_at TIMESTAMP,
    rejected_reason TEXT,
    
    auto_executable BOOLEAN DEFAULT FALSE,
    auto_executed BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_status (restaurant_id, status),
    INDEX idx_created (restaurant_id, created_at DESC)
);

-- ============================================
-- 5. ANALYTICS
-- ============================================

CREATE TABLE daily_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    
    summary_date DATE NOT NULL,
    
    total_sales DECIMAL(12,2),
    item_count INT,
    transaction_count INT,
    avg_transaction_value DECIMAL(8,2),
    
    food_costs DECIMAL(12,2),
    labor_costs DECIMAL(12,2),
    other_expenses DECIMAL(12,2),
    total_expenses DECIMAL(12,2),
    
    gross_profit DECIMAL(12,2),
    gross_margin_percent DECIMAL(5,2),
    net_profit DECIMAL(12,2),
    net_margin_percent DECIMAL(5,2),
    
    inventory_variance DECIMAL(12,2),
    customer_count INT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(restaurant_id, location_id, summary_date)
);

CREATE TABLE menu_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    menu_item_id UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
    
    performance_date DATE NOT NULL,
    
    quantity_sold INT DEFAULT 0,
    revenue DECIMAL(12,2) DEFAULT 0,
    food_cost DECIMAL(12,2) DEFAULT 0,
    gross_profit DECIMAL(12,2) DEFAULT 0,
    margin_percent DECIMAL(5,2),
    
    popularity_rank INT,
    profit_rank INT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(restaurant_id, menu_item_id, performance_date),
    INDEX idx_date_rank (restaurant_id, performance_date, popularity_rank)
);

-- ============================================
-- 6. INTEGRATIONS
-- ============================================

CREATE TABLE integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    integration_type VARCHAR(100) NOT NULL,
    config JSONB NOT NULL,
    
    status VARCHAR(50) DEFAULT 'active',
    last_sync TIMESTAMP,
    error_count INT DEFAULT 0,
    last_error TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE SET NULL,
    
    event_type VARCHAR(100) NOT NULL,
    source VARCHAR(100),
    
    data JSONB,
    status VARCHAR(50) DEFAULT 'success',
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_type (event_type),
    INDEX idx_created (created_at DESC)
);

-- ============================================
-- 7. INDEXES
-- ============================================

CREATE INDEX idx_restaurants_stripe ON restaurants(stripe_customer_id);
CREATE INDEX idx_restaurants_status ON restaurants(status);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_ingredients_restaurant ON ingredients(restaurant_id);

-- ============================================
-- 8. TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_restaurants_updated_at
BEFORE UPDATE ON restaurants
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_locations_updated_at
BEFORE UPDATE ON locations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_menu_items_updated_at
BEFORE UPDATE ON menu_items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_ingredients_updated_at
BEFORE UPDATE ON ingredients
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();
