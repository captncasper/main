#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Codespaces Setup Script Started (PrivaGuard) ---"

# --- 1. Backend Setup (Python/FastAPI) ---
echo "1. Setting up Python backend dependencies..."

# Navigate to the backend directory
# Note: In new Codespaces, the repo is directly at /workspaces/main
cd backend

# Create Python virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies from requirements.txt
echo "Installing Python dependencies..."
pip install --no-cache-dir -r requirements.txt

# Reinstall bcrypt and cryptography to resolve known startup warnings
echo "Reinstalling bcrypt and cryptography for stability..."
pip install --upgrade --force-reinstall bcrypt cryptography

# Navigate back to the root of the app
cd ..

# --- 2. Frontend Setup (Node.js/Next.js) ---
echo "2. Setting up Node.js frontend dependencies..."

# Navigate to the frontend directory
cd frontend

# Install Node.js dependencies from package.json
echo "Installing Node.js dependencies..."
npm install

# Adjust API_BASE_URL in frontend/lib/api.js to use the Codespaces public URL
echo "Updating frontend API base URL dynamically..."
CODESPACE_NAME_PREFIX=$(echo $CODESPACE_NAME | cut -d'-' -f1-4)
PUBLIC_BACKEND_URL="https://${CODESPACE_NAME_PREFIX}-8001.app.github.dev"

# Use sed to replace the hardcoded localhost URL with the dynamic public URL
# This exact sed pattern matches the 'const API_BASE_URL' line from the Canvas code.
sed -i "s|const API_BASE_URL = 'http://localhost:8001/api/v1';|const API_BASE_URL = '${PUBLIC_BACKEND_URL}/api/v1';|" lib/api.js

# Navigate back to the root of the app
cd ..

# --- 3. Database Initialization & Admin Seeding ---
echo "3. Initializing database tables..."
PYTHONPATH=./backend python backend/init_db.py

echo "4. Seeding default admin user..."
PYTHONPATH=./backend python backend/seed_admin.py

echo "--- Codespaces Setup Script Finished ---"
echo ""
echo "=========================================="
echo "        PrivaGuard Setup Complete!        "
echo "=========================================="
echo ""
echo "To run your application in this Codespace:"
echo "-----------------------------------------"
echo "1. In one terminal (from /workspaces/main):"
echo "   Run the FastAPI Backend:"
echo "   PYTHONPATH=./backend uvicorn app.main:app --reload --port 8001"
echo ""
echo "2. In a NEW terminal (from /workspaces/main/frontend):"
echo "   Run the Next.js Frontend:"
echo "   npm run dev"
echo ""
echo "3. Access your application via the Codespaces preview URL for port 3000."
echo "   (Open a new Incognito/Private browser window for best results!)"
echo "-----------------------------------------"
