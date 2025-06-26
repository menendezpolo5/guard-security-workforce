# BahinLink Security Management System

A comprehensive security workforce management platform built with modern technologies.

## 🏗️ Architecture

### Full-Stack Architecture
- **Frontend**: React with TypeScript
- **Backend**: Node.js with Express and TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Clerk
- **Deployment**: Docker & Kubernetes ready
- **Monitoring**: Prometheus & Grafana

### Project Structure
```
guard/
├── admin-portal/          # React admin dashboard
├── backend/              # Node.js API server
├── client-portal/        # Client interface
├── mobile-app/          # Mobile application
├── docs/                # Documentation
├── k8s/                 # Kubernetes configurations
├── prisma/              # Database schema & migrations
└── scripts/             # Deployment & utility scripts
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Docker (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/menendezpolo5/guard-security-workforce.git
   cd guard-security-workforce
   ```

2. **Install dependencies**
   ```bash
   npm run install:all
   ```

3. **Setup environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Initialize database**
   ```bash
   npm run db:setup
   ```

5. **Start development servers**
   ```bash
   npm run dev
   ```

## 📋 Available Scripts

- `npm run dev` - Start all development servers
- `npm run build` - Build all applications
- `npm run test` - Run all tests
- `npm run lint` - Lint all code
- `npm run db:migrate` - Run database migrations
- `npm run db:seed` - Seed database with sample data
- `npm run docker:up` - Start with Docker Compose

## 🔧 Configuration

### Environment Variables
Copy `.env.example` to `.env` and configure:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/guard_db"

# Clerk Authentication
CLERK_PUBLISHABLE_KEY="your_clerk_publishable_key"
CLERK_SECRET_KEY="your_clerk_secret_key"

# API Configuration
API_PORT=3001
FRONTEND_URL="http://localhost:3000"
```

## 🏢 Features

### Admin Portal
- **Dashboard**: Real-time workforce analytics
- **Staff Management**: Employee profiles and scheduling
- **Shift Management**: Create and assign shifts
- **Incident Reporting**: Track and manage security incidents
- **Performance Analytics**: Monitor KPIs and metrics

### Client Portal
- **Service Requests**: Submit security service requests
- **Real-time Updates**: Track service status
- **Communication**: Direct messaging with security teams
- **Reporting**: Access to incident reports

### Mobile App
- **Field Operations**: Mobile-first interface for security staff
- **Check-in/Check-out**: Location-based attendance
- **Incident Reporting**: Quick incident documentation
- **Communication**: Team messaging and alerts

## 🗄️ Database Schema

The system uses PostgreSQL with Prisma ORM. Key entities:

- **Users**: Authentication and profile management
- **Organizations**: Multi-tenant support
- **Shifts**: Work schedule management
- **Incidents**: Security incident tracking
- **Communications**: Messaging system
- **Performance**: Analytics and KPIs

## 🚀 Deployment

### Docker Deployment
```bash
docker-compose up -d
```

### Kubernetes Deployment
```bash
kubectl apply -f k8s/
```

### Production Deployment
See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed production deployment instructions.

## 📊 Monitoring

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Health Checks**: Automated system monitoring
- **Logging**: Structured application logs

## 🧪 Testing

- **Unit Tests**: Jest for component testing
- **Integration Tests**: API endpoint testing
- **E2E Tests**: Full workflow testing
- **Performance Tests**: Load and stress testing

## 📚 Documentation

- [API Documentation](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [User Guide](docs/USER_GUIDE.md)
- [Contributing Guidelines](CONTRIBUTING.md)

## 🔒 Security

- **Authentication**: Clerk-based secure authentication
- **Authorization**: Role-based access control
- **Data Protection**: Encrypted sensitive data
- **API Security**: Rate limiting and validation
- **Audit Logging**: Complete action tracking

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Check the [documentation](docs/)
- Review the [FAQ](docs/USER_GUIDE.md#faq)

## 🎯 Roadmap

- [ ] Advanced analytics dashboard
- [ ] Mobile app enhancements
- [ ] AI-powered incident prediction
- [ ] Integration with external security systems
- [ ] Multi-language support

---

**Built with ❤️ for modern security workforce management**