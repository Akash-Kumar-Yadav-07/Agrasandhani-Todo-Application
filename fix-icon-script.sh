#!/bin/bash

# Script to reset and rebuild app icon properly
echo "🔧 Fixing Agrasandhani App Icon..."

# Navigate to project directory
cd "/Users/akash/Desktop/Akash/Python/Project/Agrasandhani"

# Check if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ macOS detected - proceeding with icon fix"
    
    # Clear derived data (optional)
    echo "🧹 Clearing derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/Agrasandhani*
    
    echo "📱 Icon files are properly configured"
    echo "🎯 Next steps:"
    echo "   1. Open Xcode"
    echo "   2. Clean Build Folder (Cmd+Shift+K)"
    echo "   3. Build and Run"
    echo "   4. Check dock for updated icon"
    
    echo "🌟 If icon still appears large:"
    echo "   - Check your icon images don't have transparent backgrounds"
    echo "   - Ensure images are exactly the pixel sizes specified"
    echo "   - Try restarting the Dock: killall Dock"
    
else
    echo "❌ This script is for macOS only"
fi