# Pagy configuration
require "pagy/extras/overflow"
require "pagy/extras/metadata"

# Default items per page
Pagy::DEFAULT[:items] = 20

# Default overflow behavior
Pagy::DEFAULT[:overflow] = :empty
