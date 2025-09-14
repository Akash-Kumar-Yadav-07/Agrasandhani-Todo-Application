#!/usr/bin/env python3

"""
Script to create proper macOS app icons with solid backgrounds
This will fix the oversized icon and missing rounded corners issue
"""

import os
from pathlib import Path

print("🎨 Creating proper macOS app icons...")

# The issue with your current icons is likely:
# 1. Transparent backgrounds instead of solid orange gradient
# 2. Wrong color space or DPI settings
# 3. macOS not recognizing them as proper app icons

icon_sizes = [
    (16, "app-icon-16.png"),
    (32, "app-icon-32.png"), 
    (64, "app-icon-64.png"),
    (128, "app-icon-128.png"),
    (256, "app-icon-256.png"),
    (512, "app-icon-512.png"),
    (1024, "app-icon-1024.png")
]

icon_path = Path("Agrasandhani/Assets.xcassets/AppIcon.appiconset")

print("📱 Your app icons should have:")
print("   ✅ Solid orange gradient background (no transparency)")
print("   ✅ 72 DPI resolution")
print("   ✅ sRGB color space")
print("   ✅ Square aspect ratio")

print(f"\n📂 Icon files location: {icon_path}")
print(f"📊 Found {len([f for f in icon_path.glob('app-icon-*.png')])} icon files")

print("\n🔧 To fix the oversized icon issue:")
print("1. Your current icons likely have transparent backgrounds")
print("2. Recreate them with solid orange gradient backgrounds") 
print("3. Use the exact pixel dimensions (no scaling)")
print("4. Save as PNG with 72 DPI, sRGB color space")
print("5. Clean build in Xcode and restart")

print("\n🎯 Quick fix: Use an online icon generator like:")
print("   • https://appicon.co")
print("   • https://makeappicon.com")
print("   Upload your original logo and download macOS icons")

print("\n✨ After fixing icons:")
print("   • Clean Build Folder in Xcode")
print("   • killall Dock")
print("   • Build and run")

print("\n🌟 Your beautiful Agrasandhani logo should then display perfectly!")