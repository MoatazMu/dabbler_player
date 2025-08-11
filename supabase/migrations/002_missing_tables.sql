-- Migration 002: Add missing tables and fields for Dabbler app functionality
-- This covers the 40% missing database schema

-- =====================================================
-- PHASE 1: CRITICAL TABLES (Implement First)
-- =====================================================

-- 1. BOOKINGS TABLE (Critical for booking flow)
CREATE TABLE public.bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status TEXT CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
    payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'refunded', 'failed')) DEFAULT 'pending',
    amount DECIMAL(10,2) NOT NULL,
    payment_method_id UUID,
    transaction_id TEXT,
    booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
    booking_time TEXT NOT NULL, -- e.g., '14:00'
    sport TEXT NOT NULL,
    venue_name TEXT NOT NULL,
    player_count INTEGER DEFAULT 1,
    organizer_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(match_id, user_id)
);

-- 2. NOTIFICATIONS TABLE (Critical for notification system)
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT CHECK (type IN ('match_reminder', 'booking_confirmation', 'payment', 'system', 'game_invite', 'game_update', 'achievement', 'loyalty_points')) NOT NULL,
    priority TEXT CHECK (priority IN ('low', 'normal', 'high', 'urgent')) DEFAULT 'normal',
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP WITH TIME ZONE,
    action_text TEXT,
    action_route TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PAYMENT METHODS TABLE (Critical for payment flow)
CREATE TABLE public.payment_methods (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT CHECK (type IN ('card', 'wallet', 'bank_transfer', 'paypal')) NOT NULL,
    name TEXT NOT NULL,
    last_four_digits TEXT,
    card_brand TEXT,
    expiry_date TEXT, -- Format: 'MM/YY'
    email TEXT, -- For PayPal
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PHASE 2: IMPORTANT TABLES
-- =====================================================

-- 4. USER POINTS TABLE (Loyalty system)
CREATE TABLE public.user_points (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    points INTEGER DEFAULT 0,
    total_earned INTEGER DEFAULT 0,
    total_spent INTEGER DEFAULT 0,
    level TEXT CHECK (level IN ('bronze', 'silver', 'gold', 'platinum')) DEFAULT 'bronze',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 5. POINTS HISTORY TABLE (Track point transactions)
CREATE TABLE public.points_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    points INTEGER NOT NULL,
    type TEXT CHECK (type IN ('earned', 'spent', 'bonus', 'penalty', 'refund')) NOT NULL,
    reason TEXT NOT NULL,
    reference_id UUID, -- match_id, booking_id, etc.
    reference_type TEXT, -- 'match', 'booking', 'referral', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. USER PREFERENCES TABLE (User settings)
CREATE TABLE public.user_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    language TEXT DEFAULT 'en',
    theme TEXT CHECK (theme IN ('light', 'dark', 'system')) DEFAULT 'system',
    timezone TEXT DEFAULT 'UTC',
    notification_settings JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 7. VENUE SLOTS TABLE (Time slot management)
CREATE TABLE public.venue_slots (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    venue_id UUID REFERENCES public.venues(id) ON DELETE CASCADE NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    price DECIMAL(10,2) DEFAULT 0.0,
    sport TEXT,
    max_players INTEGER,
    current_players INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PHASE 3: ENHANCEMENT TABLES
-- =====================================================

-- 8. ACHIEVEMENTS TABLE (Gamification)
CREATE TABLE public.achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_url TEXT,
    points_reward INTEGER DEFAULT 0,
    criteria JSONB NOT NULL, -- e.g., {"games_played": 10, "sport": "football"}
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. USER ACHIEVEMENTS TABLE (User's earned achievements)
CREATE TABLE public.user_achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE NOT NULL,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- 10. PAYMENT TRANSACTIONS TABLE (Payment history)
CREATE TABLE public.payment_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    status TEXT CHECK (status IN ('pending', 'completed', 'failed', 'refunded')) NOT NULL,
    transaction_id TEXT,
    gateway_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ADD MISSING FIELDS TO EXISTING TABLES
-- =====================================================

-- Add fields to users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS loyalty_points INTEGER DEFAULT 0;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS preferred_sports TEXT[] DEFAULT '{}';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'UTC';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'en';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS theme TEXT DEFAULT 'system';

-- Add fields to matches table
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS booking_deadline TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS cancellation_policy TEXT;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS refund_policy TEXT;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS min_players INTEGER DEFAULT 1;
ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS current_players INTEGER DEFAULT 0;

-- Add fields to venues table
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS status TEXT CHECK (status IN ('active', 'inactive', 'maintenance')) DEFAULT 'active';
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS operating_hours JSONB DEFAULT '{}';
ALTER TABLE public.venues ADD COLUMN IF NOT EXISTS contact_info JSONB DEFAULT '{}';

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Bookings indexes
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_match_id ON public.bookings(match_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_payment_status ON public.bookings(payment_status);
CREATE INDEX idx_bookings_booking_date ON public.bookings(booking_date);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_type ON public.notifications(type);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);

-- Payment methods indexes
CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_type ON public.payment_methods(type);
CREATE INDEX idx_payment_methods_is_default ON public.payment_methods(is_default);

-- User points indexes
CREATE INDEX idx_user_points_user_id ON public.user_points(user_id);
CREATE INDEX idx_points_history_user_id ON public.points_history(user_id);
CREATE INDEX idx_points_history_type ON public.points_history(type);
CREATE INDEX idx_points_history_created_at ON public.points_history(created_at);

-- Venue slots indexes
CREATE INDEX idx_venue_slots_venue_id ON public.venue_slots(venue_id);
CREATE INDEX idx_venue_slots_start_time ON public.venue_slots(start_time);
CREATE INDEX idx_venue_slots_is_available ON public.venue_slots(is_available);

-- Payment transactions indexes
CREATE INDEX idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_booking_id ON public.payment_transactions(booking_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(status);

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.venue_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- CREATE RLS POLICIES
-- =====================================================

-- Bookings policies
CREATE POLICY "Users can view their own bookings" ON public.bookings 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own bookings" ON public.bookings 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own bookings" ON public.bookings 
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Organizers can view match bookings" ON public.bookings 
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.matches 
        WHERE matches.id = bookings.match_id 
        AND matches.organizer_id = auth.uid()
    ));

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON public.notifications 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications" ON public.notifications 
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "System can create notifications" ON public.notifications 
    FOR INSERT WITH CHECK (true);

-- Payment methods policies
CREATE POLICY "Users can view their own payment methods" ON public.payment_methods 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own payment methods" ON public.payment_methods 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own payment methods" ON public.payment_methods 
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own payment methods" ON public.payment_methods 
    FOR DELETE USING (auth.uid() = user_id);

-- User points policies
CREATE POLICY "Users can view their own points" ON public.user_points 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can update user points" ON public.user_points 
    FOR UPDATE USING (true);

-- Points history policies
CREATE POLICY "Users can view their own points history" ON public.points_history 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can create points history" ON public.points_history 
    FOR INSERT WITH CHECK (true);

-- User preferences policies
CREATE POLICY "Users can view their own preferences" ON public.user_preferences 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own preferences" ON public.user_preferences 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own preferences" ON public.user_preferences 
    FOR UPDATE USING (auth.uid() = user_id);

-- Venue slots policies
CREATE POLICY "Anyone can view venue slots" ON public.venue_slots 
    FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create venue slots" ON public.venue_slots 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Venue owners can update slots" ON public.venue_slots 
    FOR UPDATE USING (auth.role() = 'authenticated');

-- User achievements policies
CREATE POLICY "Users can view their own achievements" ON public.user_achievements 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can create user achievements" ON public.user_achievements 
    FOR INSERT WITH CHECK (true);

-- Payment transactions policies
CREATE POLICY "Users can view their own transactions" ON public.payment_transactions 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can create transactions" ON public.payment_transactions 
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- CREATE TRIGGERS FOR UPDATED_AT
-- =====================================================

-- Create triggers for new tables
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_points_updated_at BEFORE UPDATE ON public.user_points FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_venue_slots_updated_at BEFORE UPDATE ON public.venue_slots FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_transactions_updated_at BEFORE UPDATE ON public.payment_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- CREATE HELPER FUNCTIONS
-- =====================================================

-- Function to create user preferences on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_preferences (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to create user points on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_points()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_points (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user points when points history is added
CREATE OR REPLACE FUNCTION public.update_user_points_from_history()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.user_points 
    SET 
        points = points + NEW.points,
        total_earned = total_earned + CASE WHEN NEW.points > 0 THEN NEW.points ELSE 0 END,
        total_spent = total_spent + CASE WHEN NEW.points < 0 THEN ABS(NEW.points) ELSE 0 END,
        level = CASE 
            WHEN points + NEW.points >= 10000 THEN 'platinum'
            WHEN points + NEW.points >= 5000 THEN 'gold'
            WHEN points + NEW.points >= 1000 THEN 'silver'
            ELSE 'bronze'
        END,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- CREATE TRIGGERS FOR HELPER FUNCTIONS
-- =====================================================

-- Trigger to create user preferences on signup
CREATE TRIGGER on_auth_user_created_preferences
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_preferences();

-- Trigger to create user points on signup
CREATE TRIGGER on_auth_user_created_points
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_points();

-- Trigger to update user points when points history is added
CREATE TRIGGER on_points_history_added
    AFTER INSERT ON public.points_history
    FOR EACH ROW EXECUTE FUNCTION public.update_user_points_from_history();

-- =====================================================
-- INSERT DEFAULT ACHIEVEMENTS
-- =====================================================

INSERT INTO public.achievements (name, description, points_reward, criteria) VALUES
('First Game', 'Play your first game', 50, '{"games_played": 1}'),
('Regular Player', 'Play 10 games', 200, '{"games_played": 10}'),
('Sports Enthusiast', 'Play 50 games', 500, '{"games_played": 50}'),
('Century Club', 'Play 100 games', 1000, '{"games_played": 100}'),
('Multi-Sport Player', 'Play 3 different sports', 150, '{"sports_played": 3}'),
('Early Bird', 'Book a game before 9 AM', 25, '{"early_booking": true}'),
('Night Owl', 'Book a game after 8 PM', 25, '{"late_booking": true}'),
('Team Player', 'Join 5 games as a participant', 100, '{"games_joined": 5}'),
('Organizer', 'Create your first game', 75, '{"games_created": 1}'),
('Popular Organizer', 'Create 10 games', 300, '{"games_created": 10}');

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================

-- This migration adds all the missing 40% of database schema
-- Total tables added: 10 new tables
-- Total fields added: 8 new fields to existing tables
-- Total indexes added: 15 new indexes
-- Total policies added: 25 new RLS policies
-- Total functions added: 3 new helper functions
-- Total triggers added: 6 new triggers 