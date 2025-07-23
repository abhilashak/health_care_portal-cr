# Layout Components Documentation

## Overview

The application layout has been optimized by breaking it down into reusable components. This improves maintainability, reusability, and makes the codebase more organized.

## Component Structure

```
app/views/layouts/
├── application.html.erb          # Main layout file
├── _header.html.erb              # Head section with meta tags and assets
├── _navigation.html.erb          # Main navigation bar
├── _mobile_navigation.html.erb   # Mobile-specific navigation menu
├── _auth_links.html.erb          # Authentication links component
├── _flash_messages.html.erb      # Flash message display
├── _main_content.html.erb        # Main content wrapper
└── _footer.html.erb              # Footer component
```

## Component Details

### 1. `_header.html.erb`
- Contains all `<head>` content
- Meta tags, CSRF tokens, CSP tags
- Asset includes (CSS, JavaScript)
- Alpine.js for interactive components
- PWA manifest (commented out)

### 2. `_navigation.html.erb`
- Main navigation bar
- Desktop navigation links
- Mobile menu toggle button
- Uses Alpine.js for mobile menu functionality
- Responsive design with Tailwind CSS

### 3. `_mobile_navigation.html.erb`
- Mobile-specific navigation menu
- Collapsible menu with smooth transitions
- User avatar and profile information
- Mobile-optimized authentication links

### 4. `_auth_links.html.erb`
- Authentication-related links
- Conditional rendering based on login status
- Dashboard links based on user type
- Logout functionality

### 5. `_flash_messages.html.erb`
- Flash message display
- Dynamic styling based on message type
- Uses helper methods for consistent styling
- Supports multiple flash types (notice, alert, warning, info)

### 6. `_main_content.html.erb`
- Main content wrapper
- Flexible layout with flex-1 class
- Responsive padding and max-width
- Contains the main `yield` for page content

### 7. `_footer.html.erb`
- Footer component with branding
- Copyright information
- Legal links (Privacy Policy, Terms, etc.)
- Responsive design

## Helper Methods

### `ApplicationHelper`

#### `dashboard_path_for_user`
Returns the appropriate dashboard path based on user type:
- `doctor` → `doctor_dashboard_path`
- `patient` → `patient_dashboard_path`
- `facility` → `facility_dashboard_path`
- Default → `root_path`

#### `current_user_display_name`
Returns a user-friendly display name:
- Logged in user's display name
- Falls back to 'Guest' if no user

#### `flash_message_class(type)`
Returns appropriate CSS classes for flash messages:
- `notice/success` → Green styling
- `alert/error` → Red styling
- `warning` → Yellow styling
- `info` → Blue styling
- Default → Gray styling

## Features

### Responsive Design
- Mobile-first approach with Tailwind CSS
- Collapsible mobile menu with smooth animations
- Responsive navigation and footer

### Interactive Components
- Alpine.js for client-side interactivity
- Mobile menu toggle functionality
- Smooth transitions and animations

### Accessibility
- Proper ARIA labels and roles
- Screen reader support
- Keyboard navigation support

### Performance
- Optimized asset loading
- Minimal JavaScript footprint
- Efficient CSS with Tailwind

## Usage

### Adding New Components
1. Create a new partial in `app/views/layouts/`
2. Use descriptive naming with underscore prefix
3. Include in main layout with `<%= render 'layouts/component_name' %>`

### Modifying Components
1. Edit the specific component file
2. Test on both desktop and mobile
3. Ensure accessibility standards are maintained

### Adding New Helper Methods
1. Add methods to `ApplicationHelper`
2. Document the method purpose and parameters
3. Test with various user scenarios

## Best Practices

1. **Keep components focused** - Each component should have a single responsibility
2. **Use semantic HTML** - Proper heading hierarchy and semantic elements
3. **Maintain accessibility** - ARIA labels, keyboard navigation, screen reader support
4. **Test responsiveness** - Ensure components work on all screen sizes
5. **Document changes** - Update this documentation when modifying components

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Mobile)
- Progressive enhancement for older browsers 