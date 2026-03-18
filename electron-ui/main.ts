import { app, BrowserWindow, ipcMain } from "electron";
import path from "path";
import { spawn } from "child_process";

let mainWindow: any;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });
  mainWindow.loadFile("index.html");
}

app.whenReady().then(createWindow);

ipcMain.on("activate-extension", () => {
  // IMPORTANT: Replace with REAL path after first build
  // Or better: use electron-builder extraResources to bundle it
  const helperPath = path.join(
    __dirname,
    "../../active-helper-cli/build/Debug/ActiveHelperCLI",
  );
  // Example: "/Users/yourname/my-es-project/active-helper-cli/build/Debug/ActiveHelperCLI"

  console.log(`Launching helper: ${helperPath}`);

  const child = spawn(helperPath, [], {
    stdio: ["ignore", "pipe", "pipe"],
  });

  child.stdout.on("data", (data) => {
    const msg = data.toString().trim();
    console.log(`Helper: ${msg}`);
    mainWindow?.webContents.send("helper-output", msg);
  });

  child.stderr.on("data", (data) => {
    console.error(`Helper error: ${data}`);
  });

  child.on("close", (code) => {
    console.log(`Helper exited with code ${code}`);
    mainWindow?.webContents.send("helper-finished", code);
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
