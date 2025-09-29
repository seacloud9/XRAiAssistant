# Vendor Assets

This directory contains the vendor JavaScript libraries required for React Three Fiber support.

## Required Files

The following files need to be downloaded and placed in this directory:

### React (19.1.1)
- `react-19.1.1.min.js` - React core library
- Download from: https://unpkg.com/react@19.1.1/umd/react.production.min.js

### React DOM (19.1.1)  
- `react-dom-19.1.1.min.js` - React DOM renderer
- Download from: https://unpkg.com/react-dom@19.1.1/umd/react-dom.production.min.js

### Three.js (r171)
- `three-r171.module.js` - Three.js WebGL library
- Download from: https://unpkg.com/three@0.171.0/build/three.module.js

### React Three Fiber (8.17.10)
- `react-three-fiber-8.17.10.js` - React renderer for Three.js
- Download from: https://unpkg.com/@react-three/fiber@8.17.10/dist/index.umd.js

### Drei (9.127.3)
- `drei-9.127.3.js` - React Three Fiber helpers and abstractions
- Download from: https://unpkg.com/@react-three/drei@9.127.3/dist/index.umd.js

### Babylon.js (8.22.3)
- `babylonjs-8.22.3.js` - Babylon.js WebGL library
- Download from: https://unpkg.com/babylonjs@8.22.3/babylon.js

### A-Frame (1.7.0)
- `aframe-1.7.0.min.js` - A-Frame WebXR framework
- Download from: https://unpkg.com/aframe@1.7.0/dist/aframe-master.min.js

## File Structure

```
Vendor/
├── Vendor_README.md (this file)
├── react-19.1.1.min.js
├── react-dom-19.1.1.min.js
├── three-r171.module.js
├── react-three-fiber-8.17.10.js
├── drei-9.127.3.js
├── babylonjs-8.22.3.js
└── aframe-1.7.0.min.js
```

## Usage

These files are served via the `app://` URL scheme handler to provide dependencies for the React Three Fiber build pipeline. The WKAppURLSchemeHandler maps URLs like:

- `app://vendor/react-19.1.1.min.js` → `react-19.1.1.min.js`
- `app://vendor/react-dom-19.1.1.min.js` → `react-dom-19.1.1.min.js`
- `app://vendor/three-r171.module.js` → `three-r171.module.js`
- `app://vendor/react-three-fiber-8.17.10.js` → `react-three-fiber-8.17.10.js`
- `app://vendor/drei-9.127.3.js` → `drei-9.127.3.js`
- `app://vendor/babylonjs-8.22.3.js` → `babylonjs-8.22.3.js`
- `app://vendor/aframe-1.7.0.min.js` → `aframe-1.7.0.min.js`

## Setup Script

You can use this curl command to download all required files:

```bash
cd XRAiAssistant/XRAiAssistant/Vendor/

# React
curl -o react-19.1.1.min.js https://unpkg.com/react@19.1.1/umd/react.production.min.js

# React DOM
curl -o react-dom-19.1.1.min.js https://unpkg.com/react-dom@19.1.1/umd/react-dom.production.min.js

# Three.js
curl -o three-r171.module.js https://unpkg.com/three@0.171.0/build/three.module.js

# React Three Fiber
curl -o react-three-fiber-8.17.10.js https://unpkg.com/@react-three/fiber@8.17.10/dist/index.umd.js

# Drei
curl -o drei-9.127.3.js https://unpkg.com/@react-three/drei@9.127.3/dist/index.umd.js

# Babylon.js
curl -o babylonjs-8.22.3.js https://unpkg.com/babylonjs@8.22.3/babylon.js

# A-Frame
curl -o aframe-1.7.0.min.js https://unpkg.com/aframe@1.7.0/dist/aframe-master.min.js
```

## Version Management

When updating library versions:

1. Update the version numbers in the filenames
2. Update the mapping in `WKAppURLSchemeHandler.swift`
3. Update the build configuration in `WasmBuildService.swift`
4. Test compatibility with existing React Three Fiber scenes

## Notes

- These files are cached by the browser for performance
- All files are served with long-term cache headers (1 year)
- The build system resolves imports to these local files to avoid network dependencies
- Files are served directly from the app bundle for offline operation