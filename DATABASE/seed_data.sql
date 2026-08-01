-- =====================================================================
-- Smart Lishe Seed Data
-- Inserts static reference data required for the application to run.
-- =====================================================================

-- =====================================================================
-- System Administrator
-- =====================================================================
INSERT INTO users (id, email, password_hash, role, status, is_verified, is_active)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin@smartlishe.com',
    -- Placeholder hash for 'SecurePass123' (bcrypt hash, not actual)
    '$2b$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'admin',
    'active',
    TRUE,
    TRUE
) ON CONFLICT (email) DO NOTHING;

INSERT INTO admins (user_id, permissions)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    '["all"]'::jsonb
) ON CONFLICT (user_id) DO NOTHING;

-- =====================================================================
-- Subscription Plans
-- =====================================================================
INSERT INTO subscription_plans (id, name, description, price, currency, billing_cycle, features, is_active)
VALUES
    (uuid_generate_v4(), 'Free', 'Basic free plan with limited features', 0, 'USD', 'monthly', 
     '{"meals_per_month": 10, "ai_chats": 5, "support": "email"}'::jsonb, TRUE),
    (uuid_generate_v4(), 'Premium', 'Premium plan for advanced features', 19.99, 'USD', 'monthly',
     '{"meals_per_month": 100, "ai_chats": 50, "support": "priority", "advanced_reports": true}'::jsonb, TRUE),
    (uuid_generate_v4(), 'Professional', 'Professional plan for nutrition experts', 49.99, 'USD', 'monthly',
     '{"unlimited_meals": true, "unlimited_ai": true, "support": "24/7", "client_management": true, "analytics": true}'::jsonb, TRUE)
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- Professional Categories
-- =====================================================================
INSERT INTO professional_categories (name, description) VALUES
    ('Dietitian', 'Registered dietitian specializing in medical nutrition therapy.'),
    ('Nutritionist', 'Nutrition expert focusing on diet and wellness.'),
    ('Clinical Nutritionist', 'Nutritionist with clinical experience in healthcare settings.'),
    ('Gym Instructor', 'Fitness professional with nutrition guidance.'),
    ('Fitness Coach', 'Coach combining fitness and nutrition advice.'),
    ('Sports Nutritionist', 'Specialist in nutrition for athletes and sports performance.'),
    ('Wellness Coach', 'Holistic wellness coach integrating nutrition and lifestyle.'),
    ('Public Health Nutritionist', 'Focus on community and population nutrition.'),
    ('Pediatric Nutritionist', 'Specialist in child and adolescent nutrition.'),
    ('Nutrition Consultant', 'Independent consultant providing dietary advice.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- Food Categories
-- =====================================================================
INSERT INTO food_categories (name, description) VALUES
    ('Cereals', 'Grains and cereal products such as rice, wheat, oats.'),
    ('Legumes', 'Beans, lentils, peas, and pulses.'),
    ('Vegetables', 'Fresh and cooked vegetables.'),
    ('Fruits', 'Fresh and dried fruits.'),
    ('Fish', 'All types of fish and seafood.'),
    ('Meat', 'Poultry, red meat, and processed meats.'),
    ('Eggs', 'Chicken and other bird eggs.'),
    ('Milk & Dairy', 'Milk, cheese, yogurt, and dairy alternatives.'),
    ('Roots & Tubers', 'Potatoes, cassava, yams, etc.'),
    ('Nuts & Seeds', 'Almonds, walnuts, chia seeds, etc.'),
    ('Beverages', 'Drinks including water, juice, tea, coffee.'),
    ('Traditional Foods', 'Indigenous and traditional foods.'),
    ('Oils & Fats', 'Cooking oils, butter, margarine.'),
    ('Snacks', 'Packaged snacks and treats.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- System Settings
-- =====================================================================
INSERT INTO system_settings (key, value, description) VALUES
    ('ai_enabled', 'true', 'Enable AI features across the platform.'),
    ('default_language', '{"code": "en", "name": "English"}', 'Default language for new users.'),
    ('default_water_goal', '{"ml": 2500}', 'Default daily water goal in milliliters.'),
    ('default_calorie_goal', '{"calories": 2000}', 'Default daily calorie goal.'),
    ('support_email', '"support@smartlishe.com"', 'Support email address for contact.'),
    ('application_name', '"Smart Lishe"', 'Application display name.')
ON CONFLICT (key) DO NOTHING;

-- =====================================================================
-- Notification Templates
-- =====================================================================
INSERT INTO notification_templates (name, subject, body) VALUES
    ('Welcome', 'Welcome to Smart Lishe!', 'Hi {{name}}, welcome to Smart Lishe. Start your nutrition journey today!'),
    ('Password Reset', 'Reset your Smart Lishe password', 'Hi {{name}}, click the link to reset your password: {{link}}'),
    ('Professional Pending', 'Professional Account Pending Approval', 'Your professional account is pending admin review. You will be notified once approved.'),
    ('Professional Approved', 'Professional Account Approved', 'Congratulations {{name}}, your professional account has been approved. You can now access the professional dashboard.'),
    ('Professional Rejected', 'Professional Account Rejected', 'We regret to inform you that your professional application has been rejected. Please contact support for more details.'),
    ('Client Invitation', 'You have been invited to Smart Lishe', 'Hi {{name}}, you have been invited by {{professional}} to join Smart Lishe. Click here to set up your account: {{link}}'),
    ('Subscription Upgrade', 'Subscription Upgrade Successful', 'Your subscription has been upgraded to {{plan}}. Enjoy the new features!'),
    ('Payment Successful', 'Payment Confirmation', 'Your payment of {{amount}} {{currency}} has been successfully processed. Invoice #{{invoice}}')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- Application Settings (Language, Theme, etc.) - seed for reference only
-- =====================================================================
INSERT INTO languages (code, name, is_active) VALUES
    ('en', 'English', TRUE),
    ('sw', 'Swahili', TRUE),
    ('fr', 'French', FALSE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO themes (name, description, is_active) VALUES
    ('light', 'Light theme', TRUE),
    ('dark', 'Dark theme', TRUE)
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- Health Conditions (sample)
-- =====================================================================
INSERT INTO health_conditions (name, description) VALUES
    ('Diabetes', 'Chronic condition affecting blood sugar regulation.'),
    ('Hypertension', 'High blood pressure.'),
    ('Obesity', 'Excessive body fat.'),
    ('Celiac Disease', 'Autoimmune disorder triggered by gluten.'),
    ('Lactose Intolerance', 'Inability to digest lactose.'),
    ('Heart Disease', 'Conditions affecting the heart.'),
    ('Anemia', 'Lack of healthy red blood cells.')
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- Food Restrictions (sample)
-- =====================================================================
INSERT INTO food_restrictions (name, description) VALUES
    ('Gluten-Free', 'Avoid foods containing gluten.'),
    ('Lactose-Free', 'Avoid dairy products containing lactose.'),
    ('Low Sodium', 'Limit sodium intake.'),
    ('Low Sugar', 'Limit added sugars.'),
    ('Vegan', 'Avoid all animal products.'),
    ('Vegetarian', 'Avoid meat, fish, and poultry.'),
    ('Keto', 'Low-carb, high-fat diet.')
ON CONFLICT (name) DO NOTHING;