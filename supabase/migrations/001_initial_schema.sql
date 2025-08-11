-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE match_status AS ENUM ('upcoming', 'in_progress', 'completed', 'cancelled');
CREATE TYPE skill_level AS ENUM ('beginner', 'intermediate', 'advanced', 'professional');

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    skill_level skill_level DEFAULT 'beginner',
    games_played INTEGER DEFAULT 0,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Venues table
CREATE TABLE public.venues (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0,
    amenities TEXT[] DEFAULT '{}',
    coordinates JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Matches table
CREATE TABLE public.matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    sport TEXT NOT NULL,
    format_name TEXT NOT NULL,
    format_description TEXT NOT NULL,
    total_players INTEGER NOT NULL,
    players_per_side INTEGER NOT NULL,
    default_duration INTEGER NOT NULL, -- in minutes
    venue_id UUID REFERENCES public.venues(id) ON DELETE SET NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration INTEGER NOT NULL, -- in minutes
    price DECIMAL(10,2) DEFAULT 0.0,
    max_participants INTEGER NOT NULL,
    skill_level skill_level NOT NULL,
    amenities TEXT[] DEFAULT '{}',
    status match_status DEFAULT 'upcoming',
    organizer_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Match participants table (many-to-many relationship)
CREATE TABLE public.match_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_organizer BOOLEAN DEFAULT FALSE,
    UNIQUE(match_id, user_id)
);

-- Match waitlist table
CREATE TABLE public.match_waitlist (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(match_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_matches_sport ON public.matches(sport);
CREATE INDEX idx_matches_start_time ON public.matches(start_time);
CREATE INDEX idx_matches_venue_id ON public.matches(venue_id);
CREATE INDEX idx_matches_organizer_id ON public.matches(organizer_id);
CREATE INDEX idx_matches_status ON public.matches(status);
CREATE INDEX idx_match_participants_match_id ON public.match_participants(match_id);
CREATE INDEX idx_match_participants_user_id ON public.match_participants(user_id);
CREATE INDEX idx_venues_location ON public.venues USING GIN(to_tsvector('english', location));
CREATE INDEX idx_users_name ON public.users USING GIN(to_tsvector('english', name));

-- Create RLS (Row Level Security) policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_waitlist ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert their own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- Venues policies
CREATE POLICY "Anyone can view venues" ON public.venues FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create venues" ON public.venues FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Organizers can update venues" ON public.venues FOR UPDATE USING (auth.role() = 'authenticated');

-- Matches policies
CREATE POLICY "Anyone can view matches" ON public.matches FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create matches" ON public.matches FOR INSERT WITH CHECK (auth.uid() = organizer_id);
CREATE POLICY "Organizers can update their matches" ON public.matches FOR UPDATE USING (auth.uid() = organizer_id);
CREATE POLICY "Organizers can delete their matches" ON public.matches FOR DELETE USING (auth.uid() = organizer_id);

-- Match participants policies
CREATE POLICY "Anyone can view match participants" ON public.match_participants FOR SELECT USING (true);
CREATE POLICY "Users can join matches" ON public.match_participants FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave matches" ON public.match_participants FOR DELETE USING (auth.uid() = user_id);

-- Match waitlist policies
CREATE POLICY "Anyone can view match waitlist" ON public.match_waitlist FOR SELECT USING (true);
CREATE POLICY "Users can join waitlist" ON public.match_waitlist FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can leave waitlist" ON public.match_waitlist FOR DELETE USING (auth.uid() = user_id);

-- Create functions for automatic updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON public.venues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, name, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'name', NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user(); 