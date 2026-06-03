#!/bin/bash

# Dentago Market - Frontend Setup & Run Guide

echo "🚀 Dentago Market Frontend - Complete Setup Guide"
echo "=================================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "Download from: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ NPM version: $(npm --version)"
echo ""

# Navigate to project directory
echo "📁 Setting up Dentago Market..."
echo ""

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo "✅ Dependencies installed"
else
    echo "✅ Dependencies already installed"
fi

echo ""
echo "=================================================="
echo "🎉 Setup Complete!"
echo "=================================================="
echo ""
echo "Available Commands:"
echo "  npm run dev      - Start development server"
echo "  npm run build    - Build for production"
echo "  npm run preview  - Preview production build"
echo "  npm run lint     - Check code quality"
echo ""
echo "To start the development server, run:"
echo "  npm run dev"
echo ""
echo "Then open your browser to: http://localhost:5174"
echo ""
echo "Admin Panel Access:"
echo "  URL: http://localhost:5174/admin"
echo "  Password: dentago2026"
echo ""
echo "=================================================="
echo "Features Available:"
echo "  ✅ Marketplace - Buy/Sell dental equipment"
echo "  ✅ Technicians Hub - Connect with professionals"
echo "  ✅ Orders - Digital order management"
echo "  ✅ Clinics - Clinic directory with booking"
echo "  ✅ Academy - Learning platform"
echo "  ✅ Dashboard - CRM & Analytics"
echo "  ✅ Admin Panel - Complete site configuration"
echo ""
echo "Languages Supported:"
echo "  🇺🇿 Uzbek (uz)"
echo "  🇷🇺 Russian (ru)"
echo "  🇬🇧 English (en)"
echo ""
echo "Theme Support:"
echo "  ☀️  Light Mode"
echo "  🌙 Dark Mode"
echo "=================================================="
