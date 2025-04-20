#!/bin/zsh

# This script creates a DMG installer for Claude using PyInstaller
# No developer credentials required for distribution

echo "Creating DMG installer for Claude..."

# Application name 
APP_NAME="Claude"

# Ensure directories exist and clean up previous builds
mkdir -p dist
rm -rf dist/*.dmg dmg_temp

# Create the DMG file directly from the already built app
if [ -d "dist/$APP_NAME.app" ]; then
    echo "Adding executable permission to the app..."
    chmod -R +x "dist/$APP_NAME.app"
    
    # Apply quarantine removal to allow opening
    echo "Removing quarantine attribute to allow opening..."
    xattr -d com.apple.quarantine "dist/$APP_NAME.app" 2>/dev/null || true
    
    # Check if create-dmg is installed
    if ! command -v create-dmg &> /dev/null; then
        echo "The create-dmg tool is not installed. Installing it now..."
        if command -v brew &> /dev/null; then
            brew install create-dmg
        else
            echo "Error: Homebrew is not installed. Please install it first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    fi
    
    # Ensure background image exists
    if [ ! -f "images/dmg_background.png" ]; then
        echo "Creating background image link..."
        if [ -f "images/dmg-installer-preview.png" ]; then
            ln -sf "$(pwd)/images/dmg-installer-preview.png" "$(pwd)/images/dmg_background.png"
        else
            echo "Warning: No background image found, will use default."
        fi
    fi
    
    # Create temporary directory for DMG creation
    echo "Creating temporary directory for DMG..."
    mkdir -p dmg_temp
    cp -r "dist/$APP_NAME.app" dmg_temp/
    
    # Create a script that will be run after mounting the DMG to disable quarantine
    cat > dmg_temp/disable_quarantine.command << EOL
#!/bin/bash
# This script removes the quarantine attribute from the application
echo "Removing quarantine attribute from $APP_NAME.app..."
xattr -d com.apple.quarantine "/Applications/$APP_NAME.app" 2>/dev/null || true
echo "Done! You can now run the application."
echo "Press any key to close this window..."
read -n 1
EOL
    chmod +x dmg_temp/disable_quarantine.command
    
    # Create a simple readme file if none exists
    README_OPTION=""
    if [ -f "readme.md" ]; then
        cp readme.md dmg_temp/README.txt
        README_OPTION="--add-file README.txt dmg_temp/README.txt 220 300"
    else
        # Create a basic README
        cat > dmg_temp/README.txt << EOL
# Claude

1. Drag the application to your Applications folder
2. Run the disable_quarantine.command script to allow the app to open
3. Launch the app from your Applications folder
EOL
        README_OPTION="--add-file README.txt dmg_temp/README.txt 220 300"
    fi
    
    # Check if we have a background image
    BG_OPTION=""
    if [ -f "images/dmg_background.png" ]; then
        BG_OPTION="--background $(pwd)/images/dmg_background.png"
    fi
    
    # Build the command line with all the options
    CMD="create-dmg \
        --volname \"$APP_NAME\" \
        --window-size 600 400 \
        $BG_OPTION \
        --icon-size 128 \
        --icon \"$APP_NAME.app\" 140 150 \
        --app-drop-link 450 150 \
        --icon \"disable_quarantine.command\" 300 150 \
        $README_OPTION \
        --no-internet-enable \
        \"dist/$APP_NAME.dmg\" \
        \"dmg_temp\""
    
    # Create the DMG file
    echo "Creating DMG file..."
    echo "Running: $CMD"
    eval "$CMD"
    
    # Check if DMG creation was successful
    if [ $? -ne 0 ]; then
        echo "Error: DMG creation failed."
        # Try a simpler command if the complex one fails
        echo "Trying simpler DMG creation..."
        create-dmg \
            --volname "$APP_NAME" \
            --window-size 600 400 \
            --icon "$APP_NAME.app" 140 150 \
            --app-drop-link 450 150 \
            "dist/$APP_NAME.dmg" \
            "dmg_temp"
            
        if [ $? -ne 0 ]; then
            echo "Simple DMG creation also failed. Please check errors above."
            rm -rf dmg_temp
            exit 1
        fi
    fi
    
    # Remove temporary directory
    rm -rf dmg_temp
    
    echo "DMG installer created at: dist/$APP_NAME.dmg"
    echo "Instructions for users:"
    echo "1. Open the DMG file"
    echo "2. Drag the app to Applications folder"
    echo "3. Run the 'disable_quarantine.command' script to allow opening the app"
    echo "Done!"
else
    echo "Error: Application not found at dist/$APP_NAME.app"
    echo "Please build the application first using the build_app.sh script:"
    echo "./build_app.sh"
    exit 1
fi 