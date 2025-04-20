#!/bin/zsh

# This script builds the macOS Claude Overlay app with PyInstaller
# using the correct icon and settings

echo "Building macOS Claude Overlay app..."

# Application name
APP_NAME="Claude"

# Clean up previous builds
rm -rf build dist venv *.spec

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install pyinstaller

# Install Pillow for image conversion
pip install pillow

# Install required dependencies from the project
if [ -f "macos_claude_overlay/about/requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install -r "macos_claude_overlay/about/requirements.txt"
fi

# Also install the project in development mode
pip install -e .

# Create an icon file
ICON_FILE="macos_claude_overlay/logo/icon.icns"

# Remove any existing icon file
if [ -f "$ICON_FILE" ]; then
    rm "$ICON_FILE"
fi

# Generate a new icon file if we have the PNG logo
if [ -f "macos_claude_overlay/logo/logo_black.png" ]; then
    echo "Creating icon file from logo_black.png..."
    
    # Create a simple Python script for icon conversion
    cat > create_icon.py << EOL
from PIL import Image
import os

def create_icon():
    png_file = "macos_claude_overlay/logo/logo_black.png"
    output_dir = "macos_claude_overlay/logo"
    
    # Create iconset directory
    iconset_dir = os.path.join(output_dir, "icon.iconset")
    os.makedirs(iconset_dir, exist_ok=True)
    
    # Define the sizes needed for iconset
    sizes = [16, 32, 64, 128, 256, 512]
    
    # Generate each size
    for size in sizes:
        img = Image.open(png_file)
        # Resize with antialiasing
        img = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save 1x version
        img.save(os.path.join(iconset_dir, f"icon_{size}x{size}.png"))
        
        # Save 2x version
        img2x = Image.open(png_file)
        img2x = img2x.resize((size*2, size*2), Image.Resampling.LANCZOS)
        img2x.save(os.path.join(iconset_dir, f"icon_{size}x{size}@2x.png"))
    
    # Use iconutil to create the icns file
    os.system(f"iconutil -c icns {iconset_dir}")
    
    # Clean up
    os.system(f"rm -rf {iconset_dir}")

if __name__ == "__main__":
    create_icon()
    print("Icon created successfully")
EOL
    
    # Run the icon creation script
    python create_icon.py
    
    echo "Icon file created at: $ICON_FILE"
else
    echo "Warning: Could not find logo_black.png, the app will have no custom icon"
    ICON_FILE=""
fi

# Create spec file for PyInstaller
echo "Creating PyInstaller spec file..."

# If we have an icon, include it in the spec
ICON_CONFIG=""
if [ -f "$ICON_FILE" ]; then
    ICON_CONFIG="icon='$ICON_FILE',"
fi

cat > ${APP_NAME}.spec << EOL
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['run.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('macos_claude_overlay/logo/logo_white.png', 'macos_claude_overlay/logo'),
        ('macos_claude_overlay/logo/logo_black.png', 'macos_claude_overlay/logo'),
        ('macos_claude_overlay/about/version.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/author.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/description.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/on_pypi.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/package_name.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/classifiers.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/keywords.txt', 'macos_claude_overlay/about'),
        ('macos_claude_overlay/about/requirements.txt', 'macos_claude_overlay/about'),
    ],
    hiddenimports=['pyobjc.objc', 'pyobjc', 'Foundation', 'AppKit'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='${APP_NAME}',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=True,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    ${ICON_CONFIG}
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='${APP_NAME}',
)

app = BUNDLE(
    coll,
    name='${APP_NAME}.app',
    ${ICON_CONFIG}
    bundle_identifier='com.github.claude',
    info_plist={
        'LSUIElement': True,
        'NSHighResolutionCapable': True,
    },
)
EOL

# Build the app with PyInstaller
echo "Building the app with PyInstaller..."
pyinstaller --clean --noconfirm ${APP_NAME}.spec

# Clean up temporary files
rm -f create_icon.py

# Deactivate virtual environment
deactivate

echo "Build complete! App is available at: dist/${APP_NAME}.app"
echo "To create a DMG installer, run: ./create_dmg_simple.sh" 