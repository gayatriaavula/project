# Sample AWS CI/CD Deployment

This repository contains a sample application with frontend, backend, database, and AWS deployment infrastructure using Terraform and GitHub Actions.

## Architecture

- Frontend: Static website hosted in an S3 bucket
- Backend: Node.js Express API deployed to AWS ECS Fargate
- Database: AWS RDS MySQL instance
- Logging: AWS CloudWatch Logs for the backend service
- Infrastructure: Terraform-managed AWS resources
- CI/CD: GitHub Actions handles Terraform plan/apply, Docker image build, ECR push, ECS deployment, and frontend deployment to S3

## Features

- **Health Check**: Backend API health endpoint that returns server status and time
- **Visitor Tracking**: Database-backed visitor counter that records each API call
- **Responsive UI**: Clean, modern frontend interface
- **Automated Deployment**: Complete CI/CD pipeline with infrastructure as code

## Setup

1. Create a GitHub repository and push this project.
2. Add the following GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `DB_PASSWORD`
3. Commit to the `main` branch to trigger the GitHub Actions workflow.

## Deployment

The workflow in `.github/workflows/ci-cd.yml` will:

- initialize Terraform
- plan infrastructure changes
- apply resources on `main`
- build and push the backend container to ECR
- update the ECS service
- automatically update the frontend with the backend URL
- sync the frontend to S3

## Local Development

### Prerequisites

- Node.js (v16 or later)
- Docker
- Terraform
- AWS CLI (configured)

### Testing Locally

1. **Install backend dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Test backend with local database:**
   ```bash
   # Start a local MySQL database
   docker run --name mysql-test -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=sampledb -p 3306:3306 -d mysql:8

   # Update backend/server.js with local credentials if needed
   npm start
   ```

3. **Test frontend:**
   - Open `frontend/index.html` in a browser
   - Update `frontend/app.js` to use `http://localhost:3000` as backend URL

### API Endpoints

- `GET /api/health` - Returns server status and current time
- `GET /api/visitors` - Records a visit and returns recent visitors

## Infrastructure

The Terraform configuration creates:

- VPC with public and private subnets
- ECS Fargate cluster with backend service
- RDS MySQL database
- Application Load Balancer
- S3 bucket for static frontend hosting
- ECR repository for Docker images
- CloudWatch logging
- Security groups and IAM roles

## Notes

After deployment, Terraform outputs will provide the backend and frontend endpoints. The CI/CD pipeline automatically configures the frontend to use the correct backend URL.

For production use, consider:
- Enabling HTTPS with ACM certificates
- Setting up CloudFront CDN for the frontend
- Configuring proper backup and monitoring
- Using AWS Secrets Manager for sensitive data
