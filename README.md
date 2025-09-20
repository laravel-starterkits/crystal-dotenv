# Crystal Dotenv

A simple, robust dotenv library for Crystal that handles empty values and edge cases gracefully.

## Installation

Add this to your application's `shard.yml`:
```yaml
dependencies:
  dotenv:
    github: yourusername/crystal-dotenv



Usage :

require "dotenv"

# Load from .env file
Dotenv.load

# Load from custom file
Dotenv.load("config/.env")

# Load from multiple files
Dotenv.load(".env", ".env.local")

# Don't override existing environment variables
Dotenv.load(override: false)
