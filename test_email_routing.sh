#!/bin/bash
# Test script to verify email existence routing

echo "Testing email existence routing..."

# Test 1: Check if RPC exists in Supabase migration
if [ -f "supabase/migrations/20250810_add_user_exists_by_email.sql" ]; then
    echo "✅ Migration file exists"
else 
    echo "❌ Migration file missing"
fi

# Test 2: Check login screen routing logic
if grep -q "if (exists)" lib/features/authentication/presentation/screens/login_screen.dart; then
    if grep -q "RoutePaths.enterPassword" lib/features/authentication/presentation/screens/login_screen.dart; then
        echo "✅ Login screen routes existing users to Enter Password"
    else
        echo "❌ Login screen missing routing to Enter Password"
    fi
else
    echo "❌ Login screen missing existence check"
fi

# Test 3: Check routes are configured
if grep -q "RoutePaths.enterPassword" lib/app/app_router.dart; then
    echo "✅ Enter Password route configured"
else
    echo "❌ Enter Password route missing"
fi

echo "Test complete."
