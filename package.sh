#!/bin/bash
set -e

APP_NAME="timber"
VERSION="1.0.0"
ARCH="x86_64"
BUILD_DIR="zig-out/appimage"

echo "Building AppImage for ${APP_NAME}..."

# Create build directory
mkdir -p ${BUILD_DIR}

# Clean up any previous builds
rm -rf ${BUILD_DIR}/${APP_NAME}.AppDir
rm -f ${BUILD_DIR}/${APP_NAME}-${ARCH}.AppImage

# Create AppDir structure
mkdir -p ${BUILD_DIR}/${APP_NAME}.AppDir/usr/bin
mkdir -p ${BUILD_DIR}/${APP_NAME}.AppDir/usr/share/applications
mkdir -p ${BUILD_DIR}/${APP_NAME}.AppDir/usr/share/icons/hicolor/128x128/apps

# Copy game binary and assets
cp -r zig-out/bin/* ${BUILD_DIR}/${APP_NAME}.AppDir/usr/bin/

# Create desktop entry
cat > ${BUILD_DIR}/${APP_NAME}.AppDir/usr/share/applications/${APP_NAME}.desktop << EOF
[Desktop Entry]
Type=Application
Name=Timber
Exec=${APP_NAME}
Icon=${APP_NAME}
Categories=Game;
Terminal=false
EOF

# Copy icon
cp graphics/player128.png ${BUILD_DIR}/${APP_NAME}.AppDir/usr/share/icons/hicolor/128x128/apps/${APP_NAME}.png
cp graphics/player128.png ${BUILD_DIR}/${APP_NAME}.AppDir/${APP_NAME}.png

# Symlink desktop file to root (required by appimagetool)
ln -sf usr/share/applications/${APP_NAME}.desktop ${BUILD_DIR}/${APP_NAME}.AppDir/${APP_NAME}.desktop

# Create AppRun script
cat > ${BUILD_DIR}/${APP_NAME}.AppDir/AppRun << 'EOF'
#!/bin/sh
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
cd "${HERE}/usr/bin"
exec ./timber "$@"
EOF

chmod +x ${BUILD_DIR}/${APP_NAME}.AppDir/AppRun

# Download appimagetool if not present
if [ ! -f ${BUILD_DIR}/appimagetool-${ARCH}.AppImage ]; then
    echo "Downloading appimagetool..."
    wget -P ${BUILD_DIR} https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${ARCH}.AppImage
    chmod +x ${BUILD_DIR}/appimagetool-${ARCH}.AppImage
fi

# Create AppImage
${BUILD_DIR}/appimagetool-${ARCH}.AppImage ${BUILD_DIR}/${APP_NAME}.AppDir ${BUILD_DIR}/${APP_NAME}-${ARCH}.AppImage

echo "AppImage created: ${BUILD_DIR}/${APP_NAME}-${ARCH}.AppImage"