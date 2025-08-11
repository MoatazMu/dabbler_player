# Environment Configuration

This document explains how to set up and manage environment variables for the Dabbler app.

## Setup

1. Create a `.env` file in the root directory:
```bash
cp .env.example .env
```

2. Fill in the required environment variables in `.env`:
```
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
APP_NAME=Dabbler
ENVIRONMENT=development
```

## Required Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `APP_NAME`: The name of the app (default: "Dabbler")
- `ENVIRONMENT`: The current environment (development/production)

## Security

⚠️ **IMPORTANT**: Never commit the `.env` file to the repository. It contains sensitive information that should be kept private.

The `.env` file is already added to `.gitignore` to prevent accidental commits.

## Usage in Code

Access environment variables through the `Environment` class:

```dart
import 'package:dabbler/core/config/environment.dart';

// Access variables
final supabaseUrl = Environment.supabaseUrl;
final appName = Environment.appName;

// Check environment
if (Environment.isDevelopment) {
  // Development-specific code
}
```

## Validation

The `Environment` class automatically validates that all required variables are present when the app starts. If any required variable is missing, it will throw an exception with details about which variables are missing.
