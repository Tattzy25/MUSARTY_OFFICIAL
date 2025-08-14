-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "vector" SCHEMA extensions;

-- Create enums
CREATE TYPE api_plan AS ENUM ('free', 'pro', 'enterprise');
CREATE TYPE bundle_plan_type AS ENUM ('basic', 'premium', 'enterprise');
CREATE TYPE demo_hunt_category AS ENUM ('ui', 'animation', 'interaction', 'utility');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE submission_status AS ENUM ('pending', 'approved', 'rejected', 'on_review');
CREATE TYPE user_role AS ENUM ('user', 'admin', 'moderator');

-- Create users table (base table for foreign keys)
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    website TEXT,
    github_username TEXT,
    twitter_username TEXT,
    role user_role DEFAULT 'user',
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    last_seen_at TIMESTAMPTZ,
    stripe_customer_id TEXT,
    stripe_connect_account_id TEXT,
    paypal_email TEXT,
    total_earnings DECIMAL(10,4) DEFAULT 0,
    total_downloads INTEGER DEFAULT 0,
    total_components INTEGER DEFAULT 0
);

-- Enable RLS on users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create components table
CREATE TABLE components (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    code TEXT,
    demo_code TEXT,
    demo_dependencies TEXT[],
    dependencies TEXT[],
    dev_dependencies TEXT[],
    tailwind_config JSONB,
    css_vars JSONB,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    downloads_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT true,
    slug TEXT UNIQUE,
    preview_url TEXT,
    video_url TEXT,
    status submission_status DEFAULT 'pending',
    featured_at TIMESTAMPTZ,
    registry_dependencies TEXT[],
    is_pro BOOLEAN DEFAULT false,
    price INTEGER DEFAULT 0,
    license TEXT DEFAULT 'MIT',
    version TEXT DEFAULT '1.0.0',
    framework TEXT DEFAULT 'react',
    category TEXT,
    subcategory TEXT,
    difficulty_level INTEGER DEFAULT 1,
    estimated_time_minutes INTEGER,
    tags_cache TEXT[],
    demo_direct_registry_dependencies TEXT[],
    demo_direct_registry_dependencies_for_installation TEXT[],
    direct_registry_dependencies TEXT[],
    direct_registry_dependencies_for_installation TEXT[]
);

-- Enable RLS on components
ALTER TABLE components ENABLE ROW LEVEL SECURITY;

-- Create indexes for components
CREATE INDEX idx_components_user_id ON components(user_id);
CREATE INDEX idx_components_slug ON components(slug);
CREATE INDEX idx_components_status ON components(status);
CREATE INDEX idx_components_created_at ON components(created_at);
CREATE INDEX idx_components_is_public ON components(is_public);

-- Create api_keys table
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan api_plan DEFAULT 'free',
    requests_count INTEGER DEFAULT 0,
    requests_limit INTEGER DEFAULT 1000,
    created_at TIMESTAMPTZ DEFAULT now(),
    last_used_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    project_url TEXT
);

-- Enable RLS on api_keys
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;

-- Create indexes for api_keys
CREATE INDEX idx_api_keys_key ON api_keys(key);
CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);

-- Create tags table
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    color TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    is_featured BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0
);

-- Enable RLS on tags
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Create collections table
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    cover_url TEXT,
    user_id TEXT NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
    is_public BOOLEAN DEFAULT true,
    slug TEXT UNIQUE NOT NULL
);

-- Enable RLS on collections
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;

-- Create index for collections
CREATE INDEX idx_collections_slug ON collections(slug);

-- Create bundles table
CREATE TABLE bundles (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    is_public BOOLEAN DEFAULT false
);

-- Enable RLS on bundles
ALTER TABLE bundles ENABLE ROW LEVEL SECURITY;

-- Create code_embeddings table
CREATE TABLE code_embeddings (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    item_id INTEGER NOT NULL,
    item_type TEXT NOT NULL,
    embedding vector(1536),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for code_embeddings
CREATE INDEX idx_code_embeddings_embedding ON code_embeddings USING ivfflat (embedding vector_cosine_ops);

-- Create usage_embeddings table
CREATE TABLE usage_embeddings (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    item_id INTEGER NOT NULL,
    item_type TEXT NOT NULL,
    embedding vector(1536),
    usage_description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for usage_embeddings
CREATE INDEX idx_usage_embeddings_embedding ON usage_embeddings USING ivfflat (embedding vector_cosine_ops);

-- Create component_analytics table
CREATE TABLE component_analytics (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now(),
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    activity_type VARCHAR,
    user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
    anon_id TEXT
);

-- Enable RLS on component_analytics
ALTER TABLE component_analytics ENABLE ROW LEVEL SECURITY;

-- Create index for component_analytics
CREATE INDEX idx_component_analytics_anon_id ON component_analytics(anon_id);

-- Create component_dependencies_closure table
CREATE TABLE component_dependencies_closure (
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    dependency_component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    depth INTEGER NOT NULL,
    is_demo_dependency BOOLEAN DEFAULT false,
    PRIMARY KEY (component_id, dependency_component_id)
);

-- Enable RLS on component_dependencies_closure
ALTER TABLE component_dependencies_closure ENABLE ROW LEVEL SECURITY;

-- Create index for component_dependencies_closure
CREATE INDEX idx_component_dependencies_closure_component_id ON component_dependencies_closure(component_id);

-- Create component_hunt_rounds table
CREATE TABLE component_hunt_rounds (
    id SERIAL PRIMARY KEY,
    week_number INTEGER NOT NULL,
    start_at TIMESTAMPTZ NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    seasonal_tag_id INTEGER REFERENCES tags(id)
);

-- Enable RLS on component_hunt_rounds
ALTER TABLE component_hunt_rounds ENABLE ROW LEVEL SECURITY;

-- Create author_payouts table
CREATE TABLE author_payouts (
    id SERIAL PRIMARY KEY,
    author_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    total_amount DECIMAL(10,4) NOT NULL,
    total_usage INTEGER NOT NULL,
    paypal_email TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    transaction_id TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    processed_at TIMESTAMPTZ,
    UNIQUE(author_id, period_start, period_end)
);

-- Enable RLS on author_payouts
ALTER TABLE author_payouts ENABLE ROW LEVEL SECURITY;

-- Create indexes for author_payouts
CREATE INDEX idx_author_payouts_author_id ON author_payouts(author_id);
CREATE INDEX idx_author_payouts_period ON author_payouts(period_start, period_end);
CREATE INDEX idx_author_payouts_status ON author_payouts(status);

-- Create bundle_items table
CREATE TABLE bundle_items (
    id SERIAL PRIMARY KEY UNIQUE,
    bundle_id INTEGER NOT NULL REFERENCES bundles(id) ON DELETE CASCADE,
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS on bundle_items
ALTER TABLE bundle_items ENABLE ROW LEVEL SECURITY;

-- Create bundle_plans table
CREATE TABLE bundle_plans (
    id SERIAL PRIMARY KEY,
    bundle_id INTEGER NOT NULL REFERENCES bundles(id) ON DELETE CASCADE,
    type bundle_plan_type NOT NULL,
    description TEXT NOT NULL,
    price INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    features TEXT[] DEFAULT '{}'
);

-- Enable RLS on bundle_plans
ALTER TABLE bundle_plans ENABLE ROW LEVEL SECURITY;

-- Create bundle_purchases table
CREATE TABLE bundle_purchases (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    bundle_id INTEGER NOT NULL REFERENCES bundles(id),
    plan_id INTEGER REFERENCES bundle_plans(id),
    price INTEGER NOT NULL,
    fee REAL NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    status payment_status NOT NULL,
    paid_to_user BOOLEAN DEFAULT false
);

-- Enable RLS on bundle_purchases
ALTER TABLE bundle_purchases ENABLE ROW LEVEL SECURITY;

-- Create components_to_collections junction table
CREATE TABLE components_to_collections (
    component_id INTEGER NOT NULL REFERENCES components(id) ON DELETE CASCADE,
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (component_id, collection_id)
);

-- Enable RLS on components_to_collections
ALTER TABLE components_to_collections ENABLE ROW LEVEL SECURITY;

-- Grant permissions to anon and authenticated roles
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant permissions on extensions schema
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA extensions TO anon, authenticated;