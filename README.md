# Electron App + System Extension

# Project layout

```
my-es-project/
├── electron-ui/                # Electron app
│   ├── package.json
│   ├── main.js
│   ├── index.html
│   └── ...
├── ActiveHelper/          # Xcode project folder (Command Line Tool + System Extension target)
│   ├── ActiveHelper.xcodeproj 
│   ├── ActiveHelper/        # CLI: main.swift + files
│   └── EndpointSecurityExtension/   # extension code
└── build.sh                    # build script (no signing)
```

# Architecture

```mermaid
graph TD
    subgraph "User Space (App Bundle)"
        UI[Electron UI / TypeScript] -- "ipcMain.handle" --> MP[Electron Main Process]
        MP -- "spawn / execFile" --> NH[NativeHelper - Swift CLI]
    end

    subgraph "System Extension Framework"
        NH -- "OSSystemExtensionRequest" --> SYSD[sysextd - macOS Daemon]
        SYSD -- "User Approval" --> ESE[ESExtension - System Extension]
    end

    subgraph "Kernel & System"
        ESE -- "es_new_client" --> K[Endpoint Security Subsystem]
        K -- "es_event_t" --> ESE
    end

    subgraph "Inter-Process Communication"
        ESE -. "NSXPCConnection" .-> NH
        NH -. "Stdout / IPC" .-> MP
    end
```
