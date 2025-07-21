class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has()
  allow_browser versions: :modern

  # Basic index action for healthcare portal root route
  def index
    # This will render app/views/application/index.html.erb when created
    # For now, we'll render inline content
    render plain: "Healthcare Portal - Coming Soon"
  end
end
