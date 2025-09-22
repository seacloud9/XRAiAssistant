# Vendor Assets

This directory contains the vendor JavaScript libraries required for React Three Fiber support.

## Required Files

The following files need to be downloaded and placed in this directory:

### React (18.2.0)
- `react-18.2.0.min.js` - React core library
- Download from: https://unpkg.com/react@18.2.0/umd/react.production.min.js

### React DOM (18.2.0)  
- `react-dom-18.2.0.min.js` - React DOM renderer
- Download from: https://unpkg.com/react-dom@18.2.0/umd/react-dom.production.min.js

### Three.js (r160)
- `three-r160.module.js` - Three.js WebGL library
- Download from: https://unpkg.com/three@0.160.0/build/three.module.js

### React Three Fiber (8.15.12)
- `react-three-fiber-8.15.12.js` - React renderer for Three.js
- Download from: https://unpkg.com/@react-three/fiber@8.15.12/dist/index.umd.js

### Drei (9.88.13)
- `drei-9.88.13.js` - React Three Fiber helpers and abstractions
- Download from: https://unpkg.com/@react-three/drei@9.88.13/dist/index.umd.js

## File Structure

```
Vendor/
├── README.md (this file)
├── react-18.2.0.min.js
├── react-dom-18.2.0.min.js
├── three-r160.module.js
├── react-three-fiber-8.15.12.js
└── drei-9.88.13.js
```

## Usage

These files are served via the `app://` URL scheme handler to provide dependencies for the React Three Fiber build pipeline. The WKAppURLSchemeHandler maps URLs like:

- `app://vendor/react.production.min.js` → `react-18.2.0.min.js`
- `app://vendor/react-dom.production.min.js` → `react-dom-18.2.0.min.js`
- `app://vendor/three.module.js` → `three-r160.module.js`
- `app://vendor/react-three-fiber.js` → `react-three-fiber-8.15.12.js`
- `app://vendor/drei.js` → `drei-9.88.13.js`

## Setup Script

You can use this curl command to download all required files:

```bash
cd XRAiAssistant/XRAiAssistant/Vendor/

# React
curl -o react-18.2.0.min.js https://unpkg.com/react@18.2.0/umd/react.production.min.js

# React DOM
curl -o react-dom-18.2.0.min.js https://unpkg.com/react-dom@18.2.0/umd/react-dom.production.min.js

# Three.js
curl -o three-r160.module.js https://unpkg.com/three@0.160.0/build/three.module.js

# React Three Fiber
curl -o react-three-fiber-8.15.12.js https://unpkg.com/@react-three/fiber@8.15.12/dist/index.umd.js

# Drei
curl -o drei-9.88.13.js https://unpkg.com/@react-three/drei@9.88.13/dist/index.umd.js
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