# Load the modular seeder system
require_relative '../lib/seeds'

# Run the main seeder with default counts (100 each)
Seeds::MainSeeder.seed_all

# Alternative: Run with custom counts
# Seeds::MainSeeder.seed_all(
#   facilities: 50,
#   doctors: 75,
#   patients: 150,
#   appointments: 200
# )
