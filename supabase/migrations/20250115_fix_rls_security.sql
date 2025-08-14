-- Fix RLS security issues for code_embeddings and usage_embeddings tables
-- These tables were missing RLS protection, making them publicly accessible

-- Enable RLS on code_embeddings table
ALTER TABLE code_embeddings ENABLE ROW LEVEL SECURITY;

-- Enable RLS on usage_embeddings table
ALTER TABLE usage_embeddings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for code_embeddings
-- Allow authenticated users to read all embeddings (needed for AI search functionality)
CREATE POLICY "Allow authenticated users to read code embeddings" ON code_embeddings
    FOR SELECT TO authenticated
    USING (true);

-- Allow service role to manage embeddings (for AI functions)
CREATE POLICY "Allow service role to manage code embeddings" ON code_embeddings
    FOR ALL TO service_role
    USING (true)
    WITH CHECK (true);

-- Create RLS policies for usage_embeddings
-- Allow authenticated users to read all usage embeddings (needed for AI search functionality)
CREATE POLICY "Allow authenticated users to read usage embeddings" ON usage_embeddings
    FOR SELECT TO authenticated
    USING (true);

-- Allow service role to manage usage embeddings (for AI functions)
CREATE POLICY "Allow service role to manage usage embeddings" ON usage_embeddings
    FOR ALL TO service_role
    USING (true)
    WITH CHECK (true);

-- Add additional indexes for better performance
CREATE INDEX IF NOT EXISTS idx_code_embeddings_item_id ON code_embeddings(item_id);
CREATE INDEX IF NOT EXISTS idx_code_embeddings_item_type ON code_embeddings(item_type);
CREATE INDEX IF NOT EXISTS idx_usage_embeddings_item_id ON usage_embeddings(item_id);
CREATE INDEX IF NOT EXISTS idx_usage_embeddings_item_type ON usage_embeddings(item_type);

-- Ensure proper permissions are granted
-- Note: The original migration already grants SELECT to anon and ALL to authenticated
-- But we need to be explicit about these embedding tables since they handle sensitive AI data
GRANT SELECT ON code_embeddings TO authenticated;
GRANT SELECT ON usage_embeddings TO authenticated;

-- Revoke any existing permissions from anon role for these tables
-- (They should not be publicly accessible)
REVOKE ALL ON code_embeddings FROM anon;
REVOKE ALL ON usage_embeddings FROM anon;