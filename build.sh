#!/bin/bash
set -e

echo "=== Building ActiveHelper CLI (with code signing for entitlements) ==="
cd ActiveHelper || { echo "Folder not found – rename your Xcode project folder to ActiveHelper"; exit 1; }

xcodebuild -scheme ActiveHelper \
  -configuration Debug \
  -sdk macosx \
  build

echo ""
echo "CLI binary is in Xcode DerivedData, e.g.:"
echo "  ~/Library/Developer/Xcode/DerivedData/ActiveHelper-*/Build/Products/Debug/ActiveHelper"
echo "→ Use that path in electron-ui/main.ts; copy/symlink or bundle with Electron as needed"
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
echo "2. Run the CLI manually first to approve (use path from above):"
echo "   ~/Library/Developer/Xcode/DerivedData/ActiveHelper-<hash>/Build/Products/Debug/ActiveHelper"
echo "3. Approve in System Settings → Privacy & Security if prompted"
echo "4. Set helperPath in electron-ui/main.ts to your DerivedData ActiveHelper path"
echo "5. Launch Electron: cd electron-ui && npm start"
echo "6. Click 'Activate Extension' – watch Console.app for ES logs"
echo "   (filter: subsystem = com.e
