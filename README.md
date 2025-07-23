# 🏥 Health Care Portal

A comprehensive healthcare management system built with Ruby on Rails 8, designed to streamline healthcare facility operations, patient management, and appointment scheduling.

## 📋 Table of Contents

- [Features](#-features)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Database Setup](#-database-setup)
- [Running the Application](#-running-the-application)
- [Testing](#-testing)
- [API Documentation](#-api-documentation)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🏥 Healthcare Facility Management
- **Hospital & Clinic Management** - Complete CRUD operations for healthcare facilities
- **Facility Types** - Support for hospitals, clinics, and specialized medical centers
- **Location Services** - Address management and geographical data
- **Operating Hours** - Flexible scheduling and availability tracking
- **Insurance & Payment** - Insurance acceptance and payment processing support

### 👨‍⚕️ Doctor Management
- **Doctor Profiles** - Comprehensive doctor information and credentials
- **Specializations** - Medical specialty tracking and categorization
- **Facility Associations** - Doctor-hospital/clinic relationships
- **Availability Management** - Schedule and availability tracking
- **Experience Tracking** - Years of experience and qualifications

### 👥 Patient Management
- **Patient Records** - Complete patient information and medical history
- **Demographics** - Age groups, gender, and demographic data
- **Emergency Contacts** - Emergency contact information
- **Medical History** - Patient medical records and history
- **Insurance Information** - Insurance details and coverage

### 📅 Appointment System
- **Appointment Scheduling** - Easy appointment booking and management
- **Status Tracking** - Appointment status (scheduled, confirmed, completed, cancelled)
- **Time Slot Management** - Available time slots and duration tracking
- **Conflict Prevention** - Double-booking prevention and validation
- **Appointment Types** - Different types of appointments (routine, emergency, etc.)

### 🔍 Advanced Search & Discovery
- **Full-Text Search** - Powered by PostgreSQL pg_search for intelligent search
- **Multi-Criteria Search** - Search by name, specialization, location, and more
- **Facility Discovery** - Find hospitals and clinics by location and services
- **Doctor Search** - Find doctors by specialization and availability
- **Patient Search** - Search patient records efficiently

### 🔐 Authentication & Security
- **Multi-User Authentication** - Secure login for doctors, patients, and facilities
- **Role-Based Access** - Different dashboards and permissions per user type
- **Session Management** - Secure session handling and timeout
- **Password Security** - bcrypt password hashing
- **CSRF Protection** - Cross-site request forgery protection

### 📱 Responsive Design
- **Mobile-First Design** - Optimized for all device sizes
- **Progressive Web App** - PWA capabilities for mobile installation
- **Interactive Components** - Alpine.js for smooth user interactions
- **Accessibility** - ARIA labels and keyboard navigation support
- **Modern UI** - Clean, professional interface with Tailwind CSS

## 🛠 Technology Stack

### Backend
- **Ruby on Rails 8.0.2** - Modern web framework
- **Ruby 3.4.1** - Latest stable Ruby version
- **PostgreSQL** - Robust relational database
- **bcrypt** - Password hashing and authentication
- **pg_search** - Full-text search capabilities

### Frontend
- **Tailwind CSS** - Utility-first CSS framework
- **Alpine.js** - Lightweight JavaScript framework
- **Hotwire (Turbo + Stimulus)** - Modern Rails frontend stack
- **Import Maps** - Modern JavaScript module loading

### Development & Testing
- **RSpec** - Testing framework
- **Capybara** - Integration testing
- **Faker** - Test data generation
- **RuboCop** - Code linting and formatting
- **Brakeman** - Security vulnerability scanning

### Infrastructure
- **Docker** - Containerization support
- **Kamal** - Modern deployment tool
- **Solid Cache** - Database-backed caching
- **Solid Queue** - Background job processing
- **Solid Cable** - Real-time features

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.4.1** or higher
- **PostgreSQL 12** or higher
- **Node.js 18** or higher (for asset compilation)
- **Git** for version control
- **Docker** (optional, for containerized deployment)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd health_care_portal
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies (if using import maps)
bin/importmap:install
```

### 3. Environment Setup

```bash
# Copy environment configuration
cp config/database.yml.example config/database.yml
cp config/credentials.yml.enc.example config/credentials.yml.enc

# Edit configuration files with your settings
nano config/database.yml
```

### 4. Database Setup

```bash
# Create and setup database
rails db:create
rails db:migrate
rails db:seed
```

### 5. Start the Application

```bash
# Start the Rails server
rails server

# Or use the development script
bin/dev
```

The application will be available at `http://localhost:3000`

## ⚙️ Configuration

### Database Configuration

Edit `config/database.yml` with your PostgreSQL settings:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: localhost
  username: your_username
  password: your_password

development:
  <<: *default
  database: health_care_portal_development

test:
  <<: *default
  database: health_care_portal_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

### Environment Variables

Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost/health_care_portal_production

# Application
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_here

# Search Configuration
PG_SEARCH_DICTIONARY=english
```

## 🗄️ Database Setup

### Initial Setup

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed initial data
rails db:seed
```

### Database Structure

The application uses the following main tables:

- **healthcare_facilities** - Hospitals and clinics
- **doctors** - Medical professionals
- **patients** - Patient records
- **appointments** - Appointment scheduling
- **users** - Authentication and user management

### Search Indexes

The application includes optimized search indexes:

- **Full-text search** on facility names and addresses
- **GIN indexes** for array fields (specialties, services)
- **Composite indexes** for common queries

## 🏃‍♂️ Running the Application

### Development Mode

```bash
# Start the Rails server
rails server

# Or use the development script (includes asset compilation)
bin/dev
```

### Production Mode

```bash
# Precompile assets
rails assets:precompile

# Start production server
rails server -e production
```

### Background Jobs (Not needed for now)

```bash
# Start background job processor
rails solid_queue:start
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
rails test

# Run specific test files
rails test test/controllers/application_controller_test.rb

# Run with coverage
COVERAGE=true rails test
```

### Test Data

The application includes comprehensive test data:

```bash
# Generate test data
rails db:seed:test_data

# Reset test database
rails db:test:prepare
```

### Code Quality

```bash
# Run RuboCop for code linting
bundle exec rubocop

# Run Brakeman for security scanning
bundle exec brakeman

# Run all quality checks
bin/quality
```

## 📚 API Documentation

### RESTful Endpoints

The application provides RESTful APIs for all major entities:

#### Healthcare Facilities
```
GET    /hospitals          # List hospitals
GET    /hospitals/:id      # Show hospital
POST   /hospitals          # Create hospital
PUT    /hospitals/:id      # Update hospital
DELETE /hospitals/:id      # Delete hospital

GET    /clinics            # List clinics
GET    /clinics/:id        # Show clinic
POST   /clinics            # Create clinic
PUT    /clinics/:id        # Update clinic
DELETE /clinics/:id        # Delete clinic
```

#### Doctors
```
GET    /doctors            # List doctors
GET    /doctors/:id        # Show doctor
POST   /doctors            # Create doctor
PUT    /doctors/:id        # Update doctor
DELETE /doctors/:id        # Delete doctor

GET    /doctors/:id/appointments  # Doctor's appointments
GET    /doctors/:id/patients      # Doctor's patients
```

#### Patients
```
GET    /patients           # List patients
GET    /patients/:id       # Show patient
POST   /patients           # Create patient
PUT    /patients/:id       # Update patient
DELETE /patients/:id       # Delete patient

GET    /patients/:id/appointments  # Patient's appointments
GET    /patients/:id/doctors       # Patient's doctors
```

#### Appointments
```
GET    /appointments       # List appointments
GET    /appointments/:id   # Show appointment
POST   /appointments       # Create appointment
PUT    /appointments/:id   # Update appointment
DELETE /appointments/:id   # Delete appointment
```

### Search Endpoints

```
GET /?hospital_search=query    # Search hospitals
GET /?clinic_search=query      # Search clinics
GET /doctors?search=query      # Search doctors
GET /patients?search=query     # Search patients
```

## 🚀 Deployment

### Docker Deployment (Optional)

```bash
# Build Docker image
docker build -t health-care-portal .

# Run container
docker run -p 3000:3000 health-care-portal
```

### Kamal Deployment (Optional)

```bash
# Deploy with Kamal
kamal deploy

# Rollback if needed
kamal rollback
```

### Environment Variables

Set the following environment variables for production:

```bash
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@host/db
SECRET_KEY_BASE=your_secret_key
RAILS_SERVE_STATIC_FILES=true
```

## 🤝 Contributing

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Run tests**
   ```bash
   rails test
   ```
5. **Commit your changes**
   ```bash
   git commit -m "feat: add amazing feature"
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Create a Pull Request**

### Code Standards

- Follow Ruby style guide
- Write comprehensive tests
- Update documentation
- Use conventional commit messages
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

- **Documentation**: Check the [docs](docs/) directory
- **Issues**: Report bugs via [GitHub Issues](https://github.com/your-repo/issues)
- **Discussions**: Join [GitHub Discussions](https://github.com/your-repo/discussions)

### Common Issues

#### Database Connection Issues
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql
```

#### Asset Compilation Issues
```bash
# Clear asset cache
rails assets:clobber
rails assets:precompile
```

#### Search Issues
```bash
# Rebuild search indexes
rails db:migrate:up VERSION=20250723105928
```

## 🏆 Acknowledgments

- **Ruby on Rails** team for the amazing framework
- **Tailwind CSS** for the utility-first CSS framework
- **PostgreSQL** team for the robust database
- **Alpine.js** for lightweight interactivity
- **Hotwire** team for modern Rails frontend

---

**Built with ❤️ for better healthcare management**
