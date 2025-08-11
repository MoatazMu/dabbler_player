# Supabase Setup Guide for Dabbler App

## Overview
The Dabbler app is now connected to Supabase for real-time data management, user authentication, and profile management.

## Current Configuration
- **Project URL**: `https://vegfirgvmkppbhwbaura.supabase.co`
- **Status**: ✅ Configured and ready to use

## Database Schema
The app uses the following main tables:

### Users Table
```sql
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
```

### Additional Tables
- `bookings` - User bookings and reservations
- `notifications` - User notifications
- `payment_methods` - User payment methods
- `user_preferences` - User settings and preferences
- `user_points` - Loyalty points system
- `matches` - Game matches
- `venues` - Sports venues

## Features Implemented

### 1. User Profile Management
- ✅ Real-time profile data loading from Supabase
- ✅ Profile updates with immediate database sync
- ✅ Avatar with initials display
- ✅ Form validation and error handling

### 2. Authentication
- ✅ Supabase Auth integration
- ✅ User session management
- ✅ Secure profile access

### 3. Data Operations
- ✅ CRUD operations for user profiles
- ✅ Real-time data synchronization
- ✅ Error handling and user feedback

## How to Use

### 1. Edit Profile Screen
The edit profile screen now:
- Loads real user data from Supabase
- Shows user initials in the avatar
- Updates profile information in real-time
- Provides feedback on success/failure

### 2. Profile Data Flow
```
User Input → Form Validation → Supabase Update → Database Sync → UI Update
```

### 3. Error Handling
- Network errors are caught and displayed
- Validation errors are shown to users
- Graceful fallbacks for missing data

## Development Notes

### File Structure
```
lib/
├── core/
│   ├── config/
│   │   ├── supabase_config.dart      # Supabase configuration
│   │   └── supabase_init.dart        # Initialization helper
│   ├── services/
│   │   └── supabase_service.dart     # Main Supabase service
│   └── models/
│       └── user_model.dart           # User model with Supabase support
└── screens/
    └── profile/
        └── edit_profile_screen.dart  # Updated with Supabase integration
```

### Key Components

#### SupabaseService
- Singleton service for all Supabase operations
- Handles user profile CRUD operations
- Manages authentication state
- Provides error handling

#### UserModel
- Extended with `fromSupabaseJson()` factory
- Handles name parsing (first/last name from full name)
- Compatible with both local and Supabase data

#### EditProfileScreen
- Uses `FutureBuilder` for async data loading
- Real-time profile updates
- Loading states and error handling
- Ant Design styled avatar with initials

## Testing the Integration

### 1. Profile Loading
- Navigate to Edit Profile screen
- Should show loading indicator briefly
- Profile data should populate from database

### 2. Profile Updates
- Modify any field (name, email, phone, bio)
- Tap "Save Changes"
- Should see success message
- Data should persist in database

### 3. Error Scenarios
- Test with invalid data
- Test network connectivity issues
- Verify error messages are displayed

## Future Enhancements

### 1. Profile Image Upload
- Implement image picker integration
- Add Supabase Storage for avatar uploads
- Handle image compression and optimization

### 2. Real-time Updates
- Add real-time subscriptions for profile changes
- Implement live collaboration features

### 3. Advanced Features
- User preferences synchronization
- Notification system integration
- Payment method management

## Troubleshooting

### Common Issues

1. **"Failed to load profile data"**
   - Check Supabase connection
   - Verify user authentication
   - Check database permissions

2. **"Failed to update profile"**
   - Validate form data
   - Check network connectivity
   - Verify database constraints

3. **Avatar not showing**
   - Check if user has name data
   - Verify AvatarWidget implementation
   - Check theme configuration

### Debug Steps
1. Check console logs for Supabase errors
2. Verify Supabase project configuration
3. Test database connection
4. Check Row Level Security (RLS) policies

## Security Considerations

- All database operations use RLS policies
- User can only access their own data
- Authentication required for all operations
- Input validation on both client and server

## Performance Notes

- Profile data is cached locally
- Async operations prevent UI blocking
- Loading states provide good UX
- Error handling prevents app crashes 