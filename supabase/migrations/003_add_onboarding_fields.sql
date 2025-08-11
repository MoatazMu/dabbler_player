-- Migration: Add onboarding fields to users table
-- File: 003_add_onboarding_fields.sql

-- Add new custom types for onboarding data
CREATE TYPE user_gender AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE user_intent AS ENUM ('casual', 'competitive', 'social', 'fitness', 'professional');

-- Add onboarding fields to users table
ALTER TABLE public.users 
ADD COLUMN age INTEGER CHECK (age >= 13 AND age <= 100),
ADD COLUMN gender user_gender,
ADD COLUMN sports TEXT[] DEFAULT '{}',
ADD COLUMN intent user_intent,
ADD COLUMN onboarding_completed BOOLEAN DEFAULT FALSE,
ADD COLUMN onboarding_step TEXT DEFAULT 'phone_input',
ADD COLUMN language TEXT DEFAULT 'en',
ADD COLUMN timezone TEXT DEFAULT 'UTC',
ADD COLUMN notification_settings JSONB DEFAULT '{}',
ADD COLUMN privacy_settings JSONB DEFAULT '{}',
ADD COLUMN avatar_url TEXT;

-- Add comments for documentation
COMMENT ON COLUMN public.users.age IS 'User age (13-100)';
COMMENT ON COLUMN public.users.gender IS 'User gender preference';
COMMENT ON COLUMN public.users.sports IS 'Array of sports the user is interested in';
COMMENT ON COLUMN public.users.intent IS 'User intent for using the platform';
COMMENT ON COLUMN public.users.onboarding_completed IS 'Whether user has completed onboarding';
COMMENT ON COLUMN public.users.onboarding_step IS 'Current onboarding step';
COMMENT ON COLUMN public.users.language IS 'User preferred language (en/ar)';
COMMENT ON COLUMN public.users.timezone IS 'User timezone';
COMMENT ON COLUMN public.users.notification_settings IS 'User notification preferences';
COMMENT ON COLUMN public.users.privacy_settings IS 'User privacy preferences';
COMMENT ON COLUMN public.users.avatar_url IS 'User profile image URL';

-- Create indexes for better performance
CREATE INDEX idx_users_age ON public.users(age);
CREATE INDEX idx_users_gender ON public.users(gender);
CREATE INDEX idx_users_sports ON public.users USING GIN(sports);
CREATE INDEX idx_users_intent ON public.users(intent);
CREATE INDEX idx_users_onboarding_completed ON public.users(onboarding_completed);
CREATE INDEX idx_users_language ON public.users(language);

-- Create onboarding progress tracking table
CREATE TABLE public.onboarding_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    step_name TEXT NOT NULL,
    step_data JSONB DEFAULT '{}',
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, step_name)
);

-- Create indexes for onboarding progress
CREATE INDEX idx_onboarding_progress_user_id ON public.onboarding_progress(user_id);
CREATE INDEX idx_onboarding_progress_step_name ON public.onboarding_progress(step_name);

-- Enable RLS on onboarding_progress
ALTER TABLE public.onboarding_progress ENABLE ROW LEVEL SECURITY;

-- RLS policies for onboarding_progress
CREATE POLICY "Users can view their own onboarding progress" 
    ON public.onboarding_progress FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own onboarding progress" 
    ON public.onboarding_progress FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own onboarding progress" 
    ON public.onboarding_progress FOR UPDATE 
    USING (auth.uid() = user_id);

-- Create function to update onboarding step
CREATE OR REPLACE FUNCTION update_onboarding_step(
    p_user_id UUID,
    p_step_name TEXT,
    p_step_data JSONB DEFAULT '{}'
)
RETURNS VOID AS $$
BEGIN
    -- Update user's current onboarding step
    UPDATE public.users 
    SET onboarding_step = p_step_name,
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Insert or update onboarding progress
    INSERT INTO public.onboarding_progress (user_id, step_name, step_data, completed_at)
    VALUES (p_user_id, p_step_name, p_step_data, NOW())
    ON CONFLICT (user_id, step_name) 
    DO UPDATE SET 
        step_data = p_step_data,
        completed_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to complete onboarding
CREATE OR REPLACE FUNCTION complete_onboarding(
    p_user_id UUID,
    p_final_data JSONB DEFAULT '{}'
)
RETURNS VOID AS $$
BEGIN
    -- Mark onboarding as completed
    UPDATE public.users 
    SET onboarding_completed = TRUE,
        onboarding_step = 'completed',
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Insert completion record
    INSERT INTO public.onboarding_progress (user_id, step_name, step_data, completed_at)
    VALUES (p_user_id, 'completed', p_final_data, NOW())
    ON CONFLICT (user_id, step_name) 
    DO UPDATE SET 
        step_data = p_final_data,
        completed_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get onboarding progress
CREATE OR REPLACE FUNCTION get_onboarding_progress(p_user_id UUID)
RETURNS TABLE(
    step_name TEXT,
    completed BOOLEAN,
    completed_at TIMESTAMP WITH TIME ZONE,
    step_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        op.step_name,
        TRUE as completed,
        op.completed_at,
        op.step_data
    FROM public.onboarding_progress op
    WHERE op.user_id = p_user_id
    ORDER BY op.completed_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the handle_new_user function to include onboarding fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (
        id, 
        name, 
        email,
        phone,
        onboarding_step,
        onboarding_completed
    )
    VALUES (
        NEW.id, 
        COALESCE(NEW.raw_user_meta_data->>'name', 'Player'),
        NEW.email,
        NEW.phone,
        'phone_input',
        FALSE
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update user profile with onboarding data
CREATE OR REPLACE FUNCTION update_user_onboarding_profile(
    p_user_id UUID,
    p_name TEXT DEFAULT NULL,
    p_age INTEGER DEFAULT NULL,
    p_gender user_gender DEFAULT NULL,
    p_sports TEXT[] DEFAULT NULL,
    p_intent user_intent DEFAULT NULL,
    p_language TEXT DEFAULT NULL,
    p_avatar_url TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE public.users 
    SET 
        name = COALESCE(p_name, name),
        age = COALESCE(p_age, age),
        gender = COALESCE(p_gender, gender),
        sports = COALESCE(p_sports, sports),
        intent = COALESCE(p_intent, intent),
        language = COALESCE(p_language, language),
        avatar_url = COALESCE(p_avatar_url, avatar_url),
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION update_onboarding_step(UUID, TEXT, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_onboarding(UUID, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION get_onboarding_progress(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_onboarding_profile(UUID, TEXT, INTEGER, user_gender, TEXT[], user_intent, TEXT, TEXT) TO authenticated;

-- Create view for user onboarding status
CREATE VIEW user_onboarding_status AS
SELECT 
    u.id,
    u.name,
    u.email,
    u.onboarding_completed,
    u.onboarding_step,
    u.age,
    u.gender,
    u.sports,
    u.intent,
    u.language,
    COUNT(op.step_name) as completed_steps,
    CASE 
        WHEN u.onboarding_completed THEN 100
        ELSE (COUNT(op.step_name) * 25) -- 4 steps total
    END as progress_percentage
FROM public.users u
LEFT JOIN public.onboarding_progress op ON u.id = op.user_id
GROUP BY u.id, u.name, u.email, u.onboarding_completed, u.onboarding_step, u.age, u.gender, u.sports, u.intent, u.language;

-- Grant select on view
GRANT SELECT ON user_onboarding_status TO authenticated; 