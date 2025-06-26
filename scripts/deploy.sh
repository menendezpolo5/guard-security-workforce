#!/bin/bash

# Guard Security Workforce - Kubernetes Deployment Script
# This script deploys the entire application stack to Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="guard-security"
STAGING_NAMESPACE="guard-security-staging"
REGISTRY="ghcr.io"
REPO_NAME="menendezpolo5/guard-security-workforce"
ENVIRONMENT="production"
KUBECTL_TIMEOUT="300s"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    print_success "kubectl is available"
}

# Function to check if we can connect to Kubernetes cluster
check_cluster_connection() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        print_error "Please check your kubeconfig and cluster connectivity"
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Function to create namespaces
create_namespaces() {
    print_status "Creating namespaces..."
    kubectl apply -f k8s/namespace.yml
    print_success "Namespaces created"
}

# Function to deploy database components
deploy_database() {
    print_status "Deploying database components..."
    kubectl apply -f k8s/database.yml
    
    print_status "Waiting for PostgreSQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_status "Waiting for Redis to be ready..."
    kubectl wait --for=condition=ready pod -l app=redis -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_success "Database components deployed successfully"
}

# Function to deploy backend API
deploy_backend() {
    print_status "Deploying backend API..."
    kubectl apply -f k8s/backend.yml
    
    print_status "Waiting for backend API to be ready..."
    kubectl wait --for=condition=ready pod -l app=backend-api -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_success "Backend API deployed successfully"
}

# Function to deploy frontend applications
deploy_frontend() {
    print_status "Deploying frontend applications..."
    kubectl apply -f k8s/frontend.yml
    
    print_status "Waiting for admin portal to be ready..."
    kubectl wait --for=condition=ready pod -l app=admin-portal -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_status "Waiting for client portal to be ready..."
    kubectl wait --for=condition=ready pod -l app=client-portal -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_success "Frontend applications deployed successfully"
}

# Function to deploy monitoring stack
deploy_monitoring() {
    print_status "Deploying monitoring stack..."
    kubectl apply -f k8s/monitoring.yml
    
    print_status "Waiting for Prometheus to be ready..."
    kubectl wait --for=condition=ready pod -l app=prometheus -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_status "Waiting for Grafana to be ready..."
    kubectl wait --for=condition=ready pod -l app=grafana -n $NAMESPACE --timeout=$KUBECTL_TIMEOUT
    
    print_success "Monitoring stack deployed successfully"
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # Get the first backend pod
    BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=backend-api -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$BACKEND_POD" ]; then
        print_error "No backend pods found"
        exit 1
    fi
    
    # Run migrations
    kubectl exec -n $NAMESPACE $BACKEND_POD -- npm run db:migrate
    
    print_success "Database migrations completed"
}

# Function to seed database (optional)
seed_database() {
    if [ "$1" = "--seed" ]; then
        print_status "Seeding database..."
        
        BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=backend-api -o jsonpath='{.items[0].metadata.name}')
        
        if [ -z "$BACKEND_POD" ]; then
            print_error "No backend pods found"
            exit 1
        fi
        
        kubectl exec -n $NAMESPACE $BACKEND_POD -- npm run db:seed
        
        print_success "Database seeded successfully"
    fi
}

# Function to check deployment status
check_deployment_status() {
    print_status "Checking deployment status..."
    
    echo ""
    echo "=== Deployment Status ==="
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo "=== Services ==="
    kubectl get services -n $NAMESPACE
    
    echo ""
    echo "=== Ingress ==="
    kubectl get ingress -n $NAMESPACE
    
    echo ""
    echo "=== HPA Status ==="
    kubectl get hpa -n $NAMESPACE
}

# Function to get application URLs
get_application_urls() {
    print_status "Getting application URLs..."
    
    INGRESS_IP=$(kubectl get ingress guard-security-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    if [ -z "$INGRESS_IP" ]; then
        INGRESS_IP=$(kubectl get ingress guard-security-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    fi
    
    if [ -n "$INGRESS_IP" ]; then
        echo ""
        echo "=== Application URLs ==="
        echo "Admin Portal: https://admin.guard-security.com (${INGRESS_IP})"
        echo "Client Portal: https://client.guard-security.com (${INGRESS_IP})"
        echo "API: https://api.guard-security.com (${INGRESS_IP})"
        echo "Grafana: https://grafana.guard-security.com (${INGRESS_IP})"
        echo ""
        echo "Note: Make sure your DNS is configured to point these domains to ${INGRESS_IP}"
    else
        print_warning "Ingress IP not yet assigned. Check again in a few minutes."
    fi
}

# Function to show logs
show_logs() {
    if [ "$1" = "--logs" ]; then
        print_status "Showing recent logs..."
        
        echo ""
        echo "=== Backend API Logs ==="
        kubectl logs -n $NAMESPACE -l app=backend-api --tail=50
        
        echo ""
        echo "=== Database Logs ==="
        kubectl logs -n $NAMESPACE -l app=postgres --tail=20
    fi
}

# Function to cleanup deployment
cleanup() {
    if [ "$1" = "--cleanup" ]; then
        print_warning "This will delete all resources in the $NAMESPACE namespace"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleaning up deployment..."
            kubectl delete namespace $NAMESPACE
            print_success "Cleanup completed"
        else
            print_status "Cleanup cancelled"
        fi
        exit 0
    fi
}

# Function to show help
show_help() {
    echo "Guard Security Workforce - Kubernetes Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --environment ENV    Set environment (production|staging) [default: production]"
    echo "  --namespace NS       Set namespace [default: guard-security]"
    echo "  --seed              Seed database after deployment"
    echo "  --logs              Show logs after deployment"
    echo "  --cleanup           Delete all resources"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Deploy to production"
    echo "  $0 --environment staging     # Deploy to staging"
    echo "  $0 --seed --logs            # Deploy, seed DB, and show logs"
    echo "  $0 --cleanup                # Clean up deployment"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT="$2"
            if [ "$ENVIRONMENT" = "staging" ]; then
                NAMESPACE="$STAGING_NAMESPACE"
            fi
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --seed)
            SEED_DB="--seed"
            shift
            ;;
        --logs)
            SHOW_LOGS="--logs"
            shift
            ;;
        --cleanup)
            cleanup --cleanup
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main deployment process
main() {
    echo "=== Guard Security Workforce Deployment ==="
    echo "Environment: $ENVIRONMENT"
    echo "Namespace: $NAMESPACE"
    echo "Registry: $REGISTRY"
    echo ""
    
    # Pre-deployment checks
    check_kubectl
    check_cluster_connection
    
    # Deploy components in order
    create_namespaces
    deploy_database
    deploy_backend
    run_migrations
    seed_database $SEED_DB
    deploy_frontend
    deploy_monitoring
    
    # Post-deployment tasks
    check_deployment_status
    get_application_urls
    show_logs $SHOW_LOGS
    
    print_success "Deployment completed successfully!"
    print_status "It may take a few minutes for all services to be fully ready."
}

# Run main function
main