#!/bin/bash

# LeadInfo Complete Setup & Deployment Script
# This script handles everything from environment setup to Vercel deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install from https://nodejs.org/"
        exit 1
    fi
    print_success "Node.js $(node --version) is installed"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    print_success "npm $(npm --version) is installed"
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_warning "Git is not installed. You'll need it for Vercel deployment."
    else
        print_success "Git $(git --version | cut -d' ' -f3) is installed"
    fi
    
    # Check Vercel CLI
    if ! command -v vercel &> /dev/null; then
        print_warning "Vercel CLI is not installed. Install with: npm install -g vercel"
    else
        print_success "Vercel CLI is installed"
    fi
}

# Setup environment variables
setup_env() {
    print_header "Setting Up Environment Variables"
    
    if [ ! -f .env.local ]; then
        print_info "Creating .env.local file..."
        
        # Ask for database URL
        echo -e "${YELLOW}Enter your Neon.tech database URL:${NC}"
        echo "(Format: postgresql://user:password@host:port/db?sslmode=require)"
        read -r DB_URL
        
        # Generate AUTH_SECRET
        print_info "Generating AUTH_SECRET..."
        AUTH_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
        
        cat > .env.local << EOF
# Database Connection
DATABASE_URL="${DB_URL}"

# NextAuth Configuration
AUTH_SECRET="${AUTH_SECRET}"
AUTH_TRUST_HOST=true

# Future API Keys (Add when you get them)
PAYPAL_CLIENT_ID=""
APOLLO_API_KEY=""
CLEARBIT_API_KEY=""
EOF
        
        print_success ".env.local created successfully"
    else
        print_warning ".env.local already exists. Skipping..."
    fi
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    print_info "Running npm install..."
    npm install
    
    print_success "All dependencies installed"
}

# Setup Prisma
setup_prisma() {
    print_header "Setting Up Database with Prisma"
    
    print_info "Generating Prisma Client..."
    npx prisma generate
    
    print_info "Pushing schema to database..."
    npx prisma db push
    
    print_success "Database setup complete"
}

# Build the application
build_app() {
    print_header "Building Next.js Application"
    
    print_info "Running build..."
    npm run build
    
    print_success "Build completed successfully"
}

# Deploy to Vercel
deploy_vercel() {
    print_header "Deploying to Vercel"
    
    if ! command -v vercel &> /dev/null; then
        print_error "Vercel CLI not found. Install with: npm install -g vercel"
        exit 1
    fi
    
    print_info "Starting deployment..."
    echo ""
    echo -e "${YELLOW}Follow the prompts to complete deployment:${NC}"
    echo "1. Set up and deploy? → Yes"
    echo "2. Which scope? → Choose your account"
    echo "3. Link to existing project? → No (create new)"
    echo "4. Project name? → leadinfo (or press Enter)"
    echo "5. Directory? → ./ (press Enter)"
    echo "6. Override settings? → No"
    echo ""
    
    vercel
    
    print_info "Adding environment variables to Vercel..."
    echo -e "${YELLOW}You need to add these environment variables in Vercel Dashboard:${NC}"
    echo "1. Go to: https://vercel.com/dashboard"
    echo "2. Select your project → Settings → Environment Variables"
    echo "3. Add the following from your .env.local file:"
    echo "   - DATABASE_URL"
    echo "   - AUTH_SECRET"
    echo "   - AUTH_TRUST_HOST=true"
    echo ""
    
    print_success "Deployment initiated!"
}

# Initialize Git (if needed)
init_git() {
    print_header "Initializing Git Repository"
    
    if [ ! -d .git ]; then
        print_info "Initializing Git..."
        git init
        print_success "Git initialized"
    else
        print_warning "Git repository already exists"
    fi
}

# Push to GitHub
push_to_github() {
    print_header "Pushing to GitHub"
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        return
    fi
    
    # Check if remote is set
    if ! git remote | grep -q "origin"; then
        echo -e "${YELLOW}Enter your GitHub repository URL:${NC}"
        echo "(Format: https://github.com/username/leadinfo.git)"
        read -r GITHUB_URL
        
        git remote add origin "$GITHUB_URL"
        print_success "Remote added"
    fi
    
    print_info "Adding files..."
    git add .
    
    print_info "Creating commit..."
    git commit -m "Complete LeadInfo setup - $(date)"
    
    print_info "Pushing to GitHub..."
    git branch -M main
    git push -u origin main
    
    print_success "Code pushed to GitHub!"
    print_info "Vercel will automatically deploy your latest changes."
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   LeadInfo Complete Setup & Deployment     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_prerequisites
    setup_env
    install_dependencies
    setup_prisma
    build_app
    init_git
    push_to_github
    deploy_vercel
    
    print_header "Setup Complete! 🎉"
    echo -e "${GREEN}Your LeadInfo app is now live!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Add environment variables in Vercel Dashboard"
    echo "2. Test your app at the Vercel URL"
    echo "3. Create your first user account"
    echo ""
    echo -e "${YELLOW}To run locally:${NC} npm run dev"
    echo -e "${YELLOW}To view logs:${NC} vercel logs"
    echo ""
}

# Run main function
main "$@"