#!/bin/bash
set -e

echo "=== Building ActiveHelper CLI (no signing) ==="
cd ActiveHelper || { echo "Folder not found – rename your Xcode project folder to active-helper-cli"; exit 1; }

xcodebuild -scheme ActiveHelper \
  -configuration Debug \
  -sdk macosx \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  build

echo ""
echo "CLI binary ready at:"
echo "  $(pwd)/build/Debug/ActiveHelper"
echo "→ Copy/symlink or bundle it with Electron later"
echo ""

cd ..

echo "=== Building Electron UI ==="
cd electron-ui
npm install
npm run build

echo ""
echo "Electron app → electron-ui/dist/mac/electron-ui.app"
echo ""
echo "Quick test steps:"
echo "1. sudo systemextensionsctl developer on   # only once"
echo "2. Run the CLI manually first to approve:   ~/path/to/active-helper-cli/build/Debug/ActiveHelperCLI"
echo "3. Approve in System Settings → Privacy & Security if prompted"
echo "4. Launch Electron: cd electron-ui && npm start"
echo "5. Click 'Activate Extension' – watch Console.app for ES logs"
echo "   (filter: subsystem = com.example.myproject.activehelpercli.endpointsecurity)"
