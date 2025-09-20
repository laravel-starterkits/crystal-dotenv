# Crystal Dotenv

A simple, robust dotenv library for Crystal that handles empty values and edge cases gracefully.

## Why This Library?

Other Crystal dotenv libraries fail when encountering empty values like `DB_PASSWORD=`. This library was built to handle real-world .env files without breaking on common patterns.

## Installation

Add this to your application's `shard.yml`:
```yaml
dependencies:
  dotenv:
    github: yourusername/crystal-dotenv
    version: "~> 0.1.0"
```

```bash
Run shards install
```

```crystal
Usage

require "dotenv"

# Load from .env file (default)
Dotenv.load

# Load from custom file
Dotenv.load("config/.env")

# Load from multiple files (array syntax)
Dotenv.load(["config/.env", ".env.local"])

# Load from multiple files (splat syntax)
Dotenv.load_multiple("config/.env", ".env.local", ".env.development")

# Don't override existing environment variables
Dotenv.load(override: false)

# Get loaded variables as hash
env_vars = Dotenv.load
puts env_vars["DATABASE_URL"]?
```
