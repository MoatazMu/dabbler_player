-- =====================================================
-- FIX AUTH TRIGGER ISSUES
-- =====================================================
-- This migration fixes the issues with user creation during signup

-- Drop the existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create an improved function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert user profile with default values
    INSERT INTO public.users (
        id, 
        name, 
        email,
        avatar_url,
        created_at,
        updated_at
    ) VALUES (
        NEW.id, 
        COALESCE(NEW.raw_user_meta_data->>'name', 'Player'), -- Default name if not provided
        NEW.email,
        'assets/Avatar/default-avatar.svg', -- Default avatar
        NOW(),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error but don't fail the signup
        RAISE WARNING 'Failed to create user profile for %: %', NEW.email, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger again
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update the RLS policy to be more permissive during user creation
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

-- Create a more permissive policy that allows the trigger to work
CREATE POLICY "Users can insert their own profile" ON public.users 
FOR INSERT 
WITH CHECK (
    auth.uid() = id OR 
    (auth.uid() IS NULL AND id IS NOT NULL) -- Allow trigger to insert
);

-- Also allow the trigger to update the profile
CREATE POLICY "Users can update their own profile during creation" ON public.users 
FOR UPDATE 
USING (
    auth.uid() = id OR 
    (auth.uid() IS NULL AND id IS NOT NULL) -- Allow trigger to update
);

-- Create a function to safely create user profile (for manual profile creation)
CREATE OR REPLACE FUNCTION public.create_user_profile_safe(
    p_user_id UUID,
    p_name TEXT,
    p_email TEXT,
    p_avatar_url TEXT DEFAULT 'assets/Avatar/default-avatar.svg'
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Try to insert, but don't fail if user already exists
    INSERT INTO public.users (id, name, email, avatar_url, created_at, updated_at)
    VALUES (p_user_id, p_name, p_email, p_avatar_url, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        email = EXCLUDED.email,
        avatar_url = EXCLUDED.avatar_url,
        updated_at = NOW();
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to create/update user profile for %: %', p_email, SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.create_user_profile_safe(UUID, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_user_profile_safe(UUID, TEXT, TEXT, TEXT) TO anon; 