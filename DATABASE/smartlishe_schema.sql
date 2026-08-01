-- =====================================================================
-- Smart Lishe Database Schema
-- PostgreSQL 16+
-- Fully normalized (3NF), scalable, secure.
-- =====================================================================

-- Enable UUID extension if not already present
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================================
-- ENUM Types
-- =====================================================================

-- User roles
CREATE TYPE user_role AS ENUM ('user', 'professional', 'client', 'admin');

-- Account status
CREATE TYPE account_status AS ENUM ('active', 'inactive', 'suspended', 'pending_verification');

-- Gender
CREATE TYPE gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');

-- Lifestyle
CREATE TYPE lifestyle AS ENUM ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extra_active');

-- Diet preference
CREATE TYPE diet_preference AS ENUM ('omnivore', 'vegetarian', 'vegan', 'pescatarian', 'keto', 'paleo', 'gluten_free', 'dairy_free', 'low_carb', 'other');

-- Professional approval status
CREATE TYPE professional_approval_status AS ENUM ('pending', 'approved', 'rejected');

-- Subscription status
CREATE TYPE subscription_status AS ENUM ('active', 'expired', 'canceled', 'pending');

-- Payment status
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- Billing cycle
CREATE TYPE billing_cycle AS ENUM ('monthly', 'quarterly', 'yearly');

-- Meal type
CREATE TYPE meal_type AS ENUM ('breakfast', 'lunch', 'dinner', 'snack');

-- Difficulty level
CREATE TYPE difficulty_level AS ENUM ('easy', 'medium', 'hard');

-- =====================================================================
-- Table: users
-- Core user accounts, authentication, and basic info.
-- =====================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    status account_status NOT NULL DEFAULT 'pending_verification',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: user_profiles
-- Extended user profile information.
-- =====================================================================
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    gender gender,
    height_cm NUMERIC(5,2),          -- in centimeters
    weight_kg NUMERIC(5,2),          -- in kilograms
    bmi NUMERIC(4,2),
    lifestyle lifestyle,
    diet_preference diet_preference,
    activity_level NUMERIC(3,1),     -- scale 1-10
    water_goal_ml INT,               -- daily water goal in ml
    calorie_goal INT,                -- daily calorie goal
    allergies TEXT[],                -- array of allergies
    medical_conditions TEXT[],       -- array of conditions
    favorite_foods TEXT[],
    disliked_foods TEXT[],
    profile_picture_url TEXT,
    bio TEXT,
    settings JSONB DEFAULT '{}'::jsonb,   -- flexible settings
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_bmi ON user_profiles(bmi);

CREATE TRIGGER update_user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: password_reset_tokens
-- For password reset flow.
-- =====================================================================
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

-- =====================================================================
-- Table: email_verification_tokens
-- For email verification.
-- =====================================================================
CREATE TABLE email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_token ON email_verification_tokens(token);

-- =====================================================================
-- Table: refresh_tokens
-- For JWT refresh tokens.
-- =====================================================================
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);

-- =====================================================================
-- Table: sessions
-- Active user sessions.
-- =====================================================================
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    user_agent TEXT,
    ip_address INET,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_session_token ON sessions(session_token);

-- =====================================================================
-- Table: login_history
-- Track user logins.
-- =====================================================================
CREATE TABLE login_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    login_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_login_history_user_id ON login_history(user_id);

-- =====================================================================
-- Table: professionals
-- Extended profile for nutrition professionals.
-- =====================================================================
CREATE TABLE professionals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(100) UNIQUE,
    qualification TEXT,
    years_experience INT CHECK (years_experience >= 0),
    biography TEXT,
    consultation_fee DECIMAL(10,2) CHECK (consultation_fee >= 0),
    availability JSONB,   -- flexible schedule
    approval_status professional_approval_status NOT NULL DEFAULT 'pending',
    rating NUMERIC(3,2) CHECK (rating >= 0 AND rating <= 5),
    total_ratings INT DEFAULT 0,
    is_subscription_active BOOLEAN DEFAULT FALSE,
    subscription_plan_id UUID, -- references subscription_plans later
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_professionals_user_id ON professionals(user_id);
CREATE INDEX idx_professionals_approval_status ON professionals(approval_status);
CREATE INDEX idx_professionals_license_number ON professionals(license_number);

CREATE TRIGGER update_professionals_updated_at
BEFORE UPDATE ON professionals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: professional_categories
-- Lookup table for categories.
-- =====================================================================
CREATE TABLE professional_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_professional_categories_updated_at
BEFORE UPDATE ON professional_categories
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: professional_category_assignments
-- Many-to-many between professionals and categories.
-- =====================================================================
CREATE TABLE professional_category_assignments (
    professional_id UUID NOT NULL REFERENCES professionals(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES professional_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (professional_id, category_id)
);

-- =====================================================================
-- Table: clients
-- Extended profile for clients.
-- =====================================================================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    assigned_professional_id UUID REFERENCES professionals(id) ON DELETE SET NULL,
    invitation_token UUID UNIQUE,   -- for invitation flow
    invitation_expires_at TIMESTAMP WITH TIME ZONE,
    password_created BOOLEAN DEFAULT FALSE, -- if password set after invitation
    medical_history TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_clients_assigned_professional_id ON clients(assigned_professional_id);
CREATE INDEX idx_clients_invitation_token ON clients(invitation_token);

CREATE TRIGGER update_clients_updated_at
BEFORE UPDATE ON clients
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: admins
-- Extended profile for administrators.
-- =====================================================================
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    permissions JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_admins_user_id ON admins(user_id);

CREATE TRIGGER update_admins_updated_at
BEFORE UPDATE ON admins
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: subscription_plans
-- Predefined subscription plans.
-- =====================================================================
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE, -- 'Free', 'Premium', 'Professional'
    description TEXT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    billing_cycle billing_cycle NOT NULL DEFAULT 'monthly',
    features JSONB,   -- list of features
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscription_plans_name ON subscription_plans(name);

CREATE TRIGGER update_subscription_plans_updated_at
BEFORE UPDATE ON subscription_plans
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Add foreign key from professionals to subscription_plans after creation
ALTER TABLE professionals ADD CONSTRAINT fk_professionals_subscription_plan
    FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id) ON DELETE SET NULL;

-- =====================================================================
-- Table: user_subscriptions
-- User subscriptions (both professionals and clients? but mostly professionals)
-- We'll allow any user to have a subscription.
-- =====================================================================
CREATE TABLE user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES subscription_plans(id),
    status subscription_status NOT NULL DEFAULT 'pending',
    starts_at TIMESTAMP WITH TIME ZONE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_plan_id ON user_subscriptions(plan_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(status);

CREATE TRIGGER update_user_subscriptions_updated_at
BEFORE UPDATE ON user_subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: payments
-- Payment transactions.
-- =====================================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES user_subscriptions(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    method VARCHAR(50), -- 'card', 'paypal', etc.
    status payment_status NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(255) UNIQUE,
    invoice_number VARCHAR(100) UNIQUE,
    payment_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_subscription_id ON payments(subscription_id);
CREATE INDEX idx_payments_transaction_reference ON payments(transaction_reference);

CREATE TRIGGER update_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: invoices (optional, but we can derive from payments)
-- We'll keep separate for completeness.
-- =====================================================================
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID REFERENCES payments(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    due_at TIMESTAMP WITH TIME ZONE,
    total DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    pdf_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_payment_id ON invoices(payment_id);

CREATE TRIGGER update_invoices_updated_at
BEFORE UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: food_categories
-- Categories for foods.
-- =====================================================================
CREATE TABLE food_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_food_categories_updated_at
BEFORE UPDATE ON food_categories
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: foods
-- Food composition data.
-- =====================================================================
CREATE TABLE foods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    category_id UUID REFERENCES food_categories(id) ON DELETE SET NULL,
    serving_size VARCHAR(100), -- e.g., "100g", "1 cup"
    calories DECIMAL(8,2),
    protein DECIMAL(8,2),
    fat DECIMAL(8,2),
    carbohydrates DECIMAL(8,2),
    fiber DECIMAL(8,2),
    sugar DECIMAL(8,2),
    sodium DECIMAL(8,2),
    calcium DECIMAL(8,2),
    iron DECIMAL(8,2),
    potassium DECIMAL(8,2),
    vitamin_a DECIMAL(8,2),
    vitamin_c DECIMAL(8,2),
    source TEXT,   -- e.g., USDA
    country VARCHAR(100),
    image_url TEXT,
    search_keywords TEXT[],
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_foods_name ON foods(name);
CREATE INDEX idx_foods_category_id ON foods(category_id);
CREATE INDEX idx_foods_calories ON foods(calories);

CREATE TRIGGER update_foods_updated_at
BEFORE UPDATE ON foods
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: recipes
-- Recipe information.
-- =====================================================================
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    cuisine VARCHAR(100),
    meal_type meal_type,
    difficulty difficulty_level,
    prep_time_minutes INT,
    cook_time_minutes INT,
    total_time_minutes INT,
    servings INT,
    image_url TEXT,
    nutrition_summary JSONB, -- aggregated nutrition per serving
    is_public BOOLEAN DEFAULT TRUE,
    created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recipes_title ON recipes(title);
CREATE INDEX idx_recipes_meal_type ON recipes(meal_type);
CREATE INDEX idx_recipes_created_by ON recipes(created_by_user_id);

CREATE TRIGGER update_recipes_updated_at
BEFORE UPDATE ON recipes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: recipe_ingredients
-- Ingredients for recipes, linking to foods or free text.
-- =====================================================================
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id) ON DELETE SET NULL,
    ingredient_name VARCHAR(255) NOT NULL, -- if food_id is null, use this
    quantity DECIMAL(8,2),
    unit VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_food_id ON recipe_ingredients(food_id);

-- =====================================================================
-- Table: recipe_steps
-- Preparation steps.
-- =====================================================================
CREATE TABLE recipe_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INT NOT NULL,
    instruction TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);
CREATE UNIQUE INDEX idx_recipe_steps_unique_step ON recipe_steps(recipe_id, step_number);

-- =====================================================================
-- Table: meal_plans
-- Meal plans created by professionals or AI.
-- =====================================================================
CREATE TABLE meal_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    professional_id UUID REFERENCES professionals(id) ON DELETE SET NULL,
    created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    is_ai_generated BOOLEAN DEFAULT FALSE,
    start_date DATE,
    end_date DATE,
    daily_calories INT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meal_plans_client_id ON meal_plans(client_id);
CREATE INDEX idx_meal_plans_professional_id ON meal_plans(professional_id);
CREATE INDEX idx_meal_plans_created_by ON meal_plans(created_by_user_id);

CREATE TRIGGER update_meal_plans_updated_at
BEFORE UPDATE ON meal_plans
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: meals
-- Individual meals within a meal plan.
-- =====================================================================
CREATE TABLE meals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    meal_plan_id UUID NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    meal_type meal_type NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    custom_name VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_meals_meal_plan_id ON meals(meal_plan_id);
CREATE INDEX idx_meals_recipe_id ON meals(recipe_id);
CREATE INDEX idx_meals_scheduled_date ON meals(scheduled_date);

CREATE TRIGGER update_meals_updated_at
BEFORE UPDATE ON meals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: shopping_lists
-- Shopping lists generated from meal plans.
-- =====================================================================
CREATE TABLE shopping_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    meal_plan_id UUID REFERENCES meal_plans(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shopping_lists_client_id ON shopping_lists(client_id);
CREATE INDEX idx_shopping_lists_meal_plan_id ON shopping_lists(meal_plan_id);

CREATE TRIGGER update_shopping_lists_updated_at
BEFORE UPDATE ON shopping_lists
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: shopping_items
-- Items within a shopping list.
-- =====================================================================
CREATE TABLE shopping_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id) ON DELETE SET NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(8,2),
    unit VARCHAR(50),
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shopping_items_shopping_list_id ON shopping_items(shopping_list_id);
CREATE INDEX idx_shopping_items_food_id ON shopping_items(food_id);

-- =====================================================================
-- Table: water_logs
-- Daily water intake logs.
-- =====================================================================
CREATE TABLE water_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount_ml INT NOT NULL CHECK (amount_ml > 0),
    logged_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_water_logs_user_id ON water_logs(user_id);
CREATE INDEX idx_water_logs_log_date ON water_logs(log_date);

-- =====================================================================
-- Table: goal_tracker
-- Generic goals (fitness, nutrition, weight).
-- =====================================================================
CREATE TABLE goal_tracker (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    goal_type VARCHAR(50) NOT NULL, -- 'weight', 'calories', 'protein', etc.
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2),
    unit VARCHAR(20),
    start_date DATE NOT NULL,
    target_date DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, achieved, abandoned
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_goal_tracker_user_id ON goal_tracker(user_id);
CREATE INDEX idx_goal_tracker_status ON goal_tracker(status);

CREATE TRIGGER update_goal_tracker_updated_at
BEFORE UPDATE ON goal_tracker
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: goal_progress
-- Daily or periodic progress entries for goals.
-- =====================================================================
CREATE TABLE goal_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goal_id UUID NOT NULL REFERENCES goal_tracker(id) ON DELETE CASCADE,
    progress_date DATE NOT NULL DEFAULT CURRENT_DATE,
    value DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_goal_progress_goal_id ON goal_progress(goal_id);
CREATE INDEX idx_goal_progress_progress_date ON goal_progress(progress_date);

-- =====================================================================
-- Table: health_conditions
-- Lookup for health conditions.
-- =====================================================================
CREATE TABLE health_conditions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    icd_code VARCHAR(20), -- optional coding
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_health_conditions_updated_at
BEFORE UPDATE ON health_conditions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: user_health_conditions
-- Many-to-many for users and health conditions.
-- =====================================================================
CREATE TABLE user_health_conditions (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    condition_id UUID NOT NULL REFERENCES health_conditions(id) ON DELETE CASCADE,
    diagnosed_date DATE,
    notes TEXT,
    PRIMARY KEY (user_id, condition_id)
);

-- =====================================================================
-- Table: food_restrictions
-- Lookup for food restrictions (e.g., gluten-free, lactose intolerant).
-- =====================================================================
CREATE TABLE food_restrictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_food_restrictions_updated_at
BEFORE UPDATE ON food_restrictions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: user_food_restrictions
-- Many-to-many for users and food restrictions.
-- =====================================================================
CREATE TABLE user_food_restrictions (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    restriction_id UUID NOT NULL REFERENCES food_restrictions(id) ON DELETE CASCADE,
    notes TEXT,
    PRIMARY KEY (user_id, restriction_id)
);

-- =====================================================================
-- Table: condition_recommendations
-- Recommendations for health conditions (e.g., diet advice).
-- =====================================================================
CREATE TABLE condition_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    condition_id UUID NOT NULL REFERENCES health_conditions(id) ON DELETE CASCADE,
    recommendation TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_condition_recommendations_condition_id ON condition_recommendations(condition_id);

CREATE TRIGGER update_condition_recommendations_updated_at
BEFORE UPDATE ON condition_recommendations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: nutriscan
-- Scanned food labels.
-- =====================================================================
CREATE TABLE nutriscan (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    barcode VARCHAR(100) UNIQUE,
    food_name VARCHAR(255) NOT NULL,
    brand VARCHAR(255),
    nutrition_facts JSONB,
    ingredients TEXT,
    image_url TEXT,
    ai_analysis TEXT,
    scan_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_nutriscan_user_id ON nutriscan(user_id);
CREATE INDEX idx_nutriscan_barcode ON nutriscan(barcode);

-- =====================================================================
-- Table: ai_conversations
-- Conversations with AI assistant.
-- =====================================================================
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    context JSONB, -- e.g., diet plan context
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);

CREATE TRIGGER update_ai_conversations_updated_at
BEFORE UPDATE ON ai_conversations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: ai_messages
-- Messages within conversations.
-- =====================================================================
CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    sender VARCHAR(10) NOT NULL CHECK (sender IN ('user', 'ai')),
    content TEXT NOT NULL,
    prompt TEXT, -- the prompt used if AI
    response TEXT, -- AI response if applicable
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_messages_conversation_id ON ai_messages(conversation_id);
CREATE INDEX idx_ai_messages_sender ON ai_messages(sender);

-- =====================================================================
-- Table: ai_recommendations
-- AI-generated recommendations (e.g., meal suggestions).
-- =====================================================================
CREATE TABLE ai_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL, -- 'meal_plan', 'recipe', 'tip'
    content JSONB NOT NULL,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_accepted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_recommendations_user_id ON ai_recommendations(user_id);

-- =====================================================================
-- Table: reports
-- Generated reports (PDF or data).
-- =====================================================================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL, -- 'progress', 'nutrition', 'analytics'
    title VARCHAR(255) NOT NULL,
    content JSONB, -- structured data
    file_url TEXT,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reports_user_id ON reports(user_id);
CREATE INDEX idx_reports_report_type ON reports(report_type);

-- =====================================================================
-- Table: notifications
-- User notifications.
-- =====================================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- =====================================================================
-- Table: notification_templates
-- Predefined templates for notifications.
-- =====================================================================
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    subject VARCHAR(255),
    body TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_notification_templates_updated_at
BEFORE UPDATE ON notification_templates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: notification_preferences
-- User preferences for notifications.
-- =====================================================================
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    preferences JSONB DEFAULT '{}'::jsonb, -- fine-grained
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_notification_preferences_updated_at
BEFORE UPDATE ON notification_preferences
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: contact_messages
-- Contact/Support requests.
-- =====================================================================
CREATE TABLE contact_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- pending, resolved
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contact_messages_user_id ON contact_messages(user_id);
CREATE INDEX idx_contact_messages_status ON contact_messages(status);

CREATE TRIGGER update_contact_messages_updated_at
BEFORE UPDATE ON contact_messages
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: system_settings
-- Global system settings.
-- =====================================================================
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_system_settings_key ON system_settings(key);

CREATE TRIGGER update_system_settings_updated_at
BEFORE UPDATE ON system_settings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: application_settings
-- User-level application settings.
-- =====================================================================
CREATE TABLE application_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    language VARCHAR(10) DEFAULT 'en',
    theme VARCHAR(20) DEFAULT 'light',
    timezone VARCHAR(50) DEFAULT 'UTC',
    currency VARCHAR(3) DEFAULT 'USD',
    country VARCHAR(100),
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_application_settings_updated_at
BEFORE UPDATE ON application_settings
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- Table: languages
-- Supported languages (for reference).
-- =====================================================================
CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================================
-- Table: themes
-- Supported themes (for reference).
-- =====================================================================
CREATE TABLE themes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================================
-- Table: files
-- File uploads (profile pics, certificates, meal images).
-- =====================================================================
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(100),
    file_type VARCHAR(50), -- 'profile', 'certificate', 'meal_image'
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_files_user_id ON files(user_id);
CREATE INDEX idx_files_file_type ON files(file_type);

-- =====================================================================
-- Table: audit_logs
-- Audit trail for admin actions and critical events.
-- =====================================================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,
    changes JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity_type_entity_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =====================================================================
-- Table: activity_logs
-- User activity logs (e.g., page views, actions).
-- =====================================================================
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    activity_type VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activity_logs_user_id ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_activity_type ON activity_logs(activity_type);

-- =====================================================================
-- Additional Indexes for Performance (optional)
-- =====================================================================
-- Index on users for is_active and role combination
CREATE INDEX idx_users_role_active ON users(role, is_active);

-- Index on professionals for approval_status and rating
CREATE INDEX idx_professionals_approval_rating ON professionals(approval_status, rating DESC);

-- Index on meal_plans for date range
CREATE INDEX idx_meal_plans_date_range ON meal_plans(start_date, end_date);

-- Index on water_logs for date and user
CREATE INDEX idx_water_logs_user_date ON water_logs(user_id, log_date);

-- Index on goal_progress for goal and date
CREATE INDEX idx_goal_progress_goal_date ON goal_progress(goal_id, progress_date);

-- =====================================================================
-- Comments for documentation
-- =====================================================================
COMMENT ON DATABASE smartlishe_db IS 'Database for Smart Lishe AI-powered nutrition and diet management platform.';

COMMENT ON TABLE users IS 'Core user accounts with authentication and role.';
COMMENT ON TABLE user_profiles IS 'Extended profile information for users.';
COMMENT ON TABLE professionals IS 'Professionals extending users with approval and subscription.';
COMMENT ON TABLE clients IS 'Clients extending users, linked to professionals via invitation.';
COMMENT ON TABLE admins IS 'Administrators extending users.';

COMMENT ON TABLE foods IS 'Food composition database with nutritional values.';
COMMENT ON TABLE recipes IS 'Recipes with ingredients and steps.';
COMMENT ON TABLE meal_plans IS 'Meal plans created for clients by professionals or AI.';
COMMENT ON TABLE water_logs IS 'Daily water intake tracking.';
COMMENT ON TABLE goal_tracker IS 'User goals for nutrition, fitness, weight.';
COMMENT ON TABLE nutriscan IS 'Scanned food labels with AI analysis.';
COMMENT ON TABLE ai_conversations IS 'Conversations with the AI assistant.';
COMMENT ON TABLE notifications IS 'User notifications.';
COMMENT ON TABLE audit_logs IS 'Audit trail for administrative actions.';