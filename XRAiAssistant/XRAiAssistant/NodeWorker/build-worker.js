const esbuild = require('esbuild');
const path = require('path');
const fs = require('fs');

// Cache for built modules to improve performance
const buildCache = new Map();
const dependencyCache = new Map();

// Performance tracking
let buildStats = {
    totalBuilds: 0,
    cacheHits: 0,
    averageBuildTime: 0,
    lastBuildTime: 0
};

// Message handling for React Native bridge
const channel = process.env.NODEJS_MOBILE_BUILD_WORKER_PORT ? 
    require('rn-bridge') : 
    { send: console.log, on: () => {} }; // Fallback for testing

// Initialize worker
console.log('🚀 XRAiAssistant Node.js Build Worker starting...');
console.log('📊 esbuild version:', require('esbuild/package.json').version);

// Vendor asset mappings for app:// protocol
const vendorMappings = {
    'react': 'app://vendor/react.production.min.js',
    'react-dom': 'app://vendor/react-dom.production.min.js',
    'react-dom/client': 'app://vendor/react-dom.production.min.js',
    'three': 'app://vendor/three.module.js',
    '@react-three/fiber': 'app://vendor/react-three-fiber.js',
    '@react-three/drei': 'app://vendor/drei.js',
    'reactylon': 'app://vendor/reactylon.js',
    '@babylonjs/core': 'app://vendor/babylonjs.js'
};

// Enhanced resolver plugin for vendor dependencies
function createVendorResolverPlugin() {
    return {
        name: 'vendor-resolver',
        setup(build) {
            // Resolve bare imports to vendor URLs
            build.onResolve({ filter: /.*/ }, (args) => {
                // Skip relative and absolute imports
                if (args.path.startsWith('./') || args.path.startsWith('../') || args.path.startsWith('/')) {
                    return undefined;
                }
                
                // Check if we have a vendor mapping
                if (vendorMappings[args.path]) {
                    return {
                        path: vendorMappings[args.path],
                        external: true,
                        namespace: 'vendor'
                    };
                }
                
                // Handle scoped packages and subpaths
                for (const [packageName, vendorUrl] of Object.entries(vendorMappings)) {
                    if (args.path.startsWith(packageName + '/')) {
                        return {
                            path: vendorUrl,
                            external: true,
                            namespace: 'vendor'
                        };
                    }
                }
                
                return undefined;
            });
        }
    };
}

// Build caching system
function getCacheKey(request) {
    return JSON.stringify({
        framework: request.framework,
        entry: request.entry,
        files: request.files,
        defines: request.defines,
        minify: request.minify
    });
}

function getCachedBuild(cacheKey) {
    const cached = buildCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < 300000) { // 5 minute cache
        return cached.result;
    }
    return null;
}

function setCachedBuild(cacheKey, result) {
    buildCache.set(cacheKey, {
        result,
        timestamp: Date.now()
    });
    
    // Limit cache size
    if (buildCache.size > 100) {
        const firstKey = buildCache.keys().next().value;
        buildCache.delete(firstKey);
    }
}

// Enhanced build function with caching and performance optimization
async function buildCode(request) {
    const startTime = Date.now();
    
    try {
        console.log(`🏗️ Building ${request.framework} code (${Object.keys(request.files).length} files)`);
        
        // Check cache first
        const cacheKey = getCacheKey(request);
        const cachedResult = getCachedBuild(cacheKey);
        
        if (cachedResult) {
            buildStats.cacheHits++;
            console.log(`⚡ Cache hit! Returning cached build`);
            
            return {
                status: 'ok',
                bundleCode: cachedResult.bundleCode,
                warnings: cachedResult.warnings,
                errors: [],
                bytes: cachedResult.bytes,
                durationMs: Date.now() - startTime,
                fromCache: true
            };
        }
        
        // Create virtual file system
        const entryContent = request.files[request.entry];
        if (!entryContent) {
            throw new Error(`Entry file not found: ${request.entry}`);
        }
        
        // Determine loader based on file extension
        const entryExt = path.extname(request.entry).slice(1);
        const loader = getLoaderForExtension(entryExt, request.framework);
        
        // Configure build options
        const buildOptions = {
            stdin: {
                contents: entryContent,
                loader: loader,
                resolveDir: '/src'
            },
            bundle: true,
            platform: 'browser',
            format: 'iife',
            globalName: 'XRAiApp',
            target: 'es2020',
            jsx: request.framework === 'reactThreeFiber' || request.framework === 'reactylon' ? 'automatic' : undefined,
            jsxDev: false,
            minify: request.minify || false,
            sourcemap: 'inline',
            write: false,
            metafile: true,
            define: {
                'process.env.NODE_ENV': '"production"',
                'global': 'globalThis',
                ...request.defines
            },
            plugins: [
                createVendorResolverPlugin(),
                createVirtualFileSystemPlugin(request.files)
            ],
            external: [],
            logLevel: 'warning'
        };
        
        // Perform the build
        console.log(`⚙️ Running esbuild with ${loader} loader...`);
        const result = await esbuild.build(buildOptions);
        
        const bundleCode = result.outputFiles?.[0]?.text || '';
        const bytes = new TextEncoder().encode(bundleCode).length;
        const durationMs = Date.now() - startTime;
        
        // Extract warnings and errors
        const warnings = result.warnings?.map(w => formatEsbuildMessage(w)) || [];
        const errors = result.errors?.map(e => formatEsbuildMessage(e)) || [];
        
        // Prepare result
        const buildResult = {
            status: errors.length > 0 ? 'error' : 'ok',
            bundleCode: errors.length > 0 ? null : bundleCode,
            warnings,
            errors,
            bytes,
            durationMs,
            fromCache: false,
            metafile: result.metafile
        };
        
        // Cache successful builds
        if (buildResult.status === 'ok') {
            setCachedBuild(cacheKey, {
                bundleCode: buildResult.bundleCode,
                warnings: buildResult.warnings,
                bytes: buildResult.bytes
            });
        }
        
        // Update statistics
        buildStats.totalBuilds++;
        buildStats.lastBuildTime = durationMs;
        buildStats.averageBuildTime = 
            (buildStats.averageBuildTime * (buildStats.totalBuilds - 1) + durationMs) / buildStats.totalBuilds;
        
        console.log(`✅ Build completed in ${durationMs}ms (${(bytes/1024).toFixed(1)}KB)`);
        console.log(`📊 Stats: ${buildStats.totalBuilds} builds, ${buildStats.cacheHits} cache hits, avg ${buildStats.averageBuildTime.toFixed(0)}ms`);
        
        return buildResult;
        
    } catch (error) {
        const durationMs = Date.now() - startTime;
        console.error('❌ Build error:', error);
        
        return {
            status: 'error',
            bundleCode: null,
            warnings: [],
            errors: [error.message || 'Unknown build error'],
            bytes: 0,
            durationMs,
            fromCache: false
        };
    }
}

// Helper function to determine the correct loader
function getLoaderForExtension(ext, framework) {
    switch (ext) {
        case 'tsx': return 'tsx';
        case 'ts': return 'ts';
        case 'jsx': return 'jsx';
        case 'js': 
        default:
            // For React frameworks, use JSX loader for JS files too
            return (framework === 'reactThreeFiber' || framework === 'reactylon') ? 'jsx' : 'js';
    }
}

// Virtual file system plugin for handling multiple files
function createVirtualFileSystemPlugin(files) {
    return {
        name: 'virtual-fs',
        setup(build) {
            build.onResolve({ filter: /.*/ }, (args) => {
                // Handle relative imports within the virtual file system
                if (args.path.startsWith('./') || args.path.startsWith('../')) {
                    const resolvedPath = path.resolve(path.dirname(args.importer || '/src'), args.path);
                    const normalizedPath = resolvedPath.replace(/\\/g, '/');
                    
                    if (files[normalizedPath]) {
                        return {
                            path: normalizedPath,
                            namespace: 'virtual'
                        };
                    }
                }
                
                // Check absolute paths in virtual file system
                if (files[args.path]) {
                    return {
                        path: args.path,
                        namespace: 'virtual'
                    };
                }
                
                return undefined;
            });
            
            build.onLoad({ filter: /.*/, namespace: 'virtual' }, (args) => {
                const content = files[args.path];
                if (content === undefined) {
                    return {
                        errors: [{
                            text: `File not found in virtual file system: ${args.path}`,
                            location: null
                        }]
                    };
                }
                
                const ext = path.extname(args.path).slice(1);
                const loader = getLoaderForExtension(ext, 'auto');
                
                return {
                    contents: content,
                    loader: loader
                };
            });
        }
    };
}

// Format esbuild messages for better display
function formatEsbuildMessage(message) {
    let formatted = message.text;
    
    if (message.location) {
        const { file, line, column } = message.location;
        formatted = `${file}:${line}:${column}: ${formatted}`;
        
        if (message.location.lineText) {
            formatted += `\n${message.location.lineText}`;
            if (column) {
                formatted += '\n' + ' '.repeat(column - 1) + '^';
            }
        }
    }
    
    return formatted;
}

// Clear cache function
function clearCache() {
    buildCache.clear();
    dependencyCache.clear();
    console.log('🗑️ Build cache cleared');
}

// Get performance statistics
function getStats() {
    return {
        ...buildStats,
        cacheSize: buildCache.size,
        uptime: process.uptime()
    };
}

// Message handler
async function handleMessage(data) {
    try {
        const message = typeof data === 'string' ? JSON.parse(data) : data;
        
        switch (message.cmd) {
            case 'build':
                const result = await buildCode(message);
                channel.send(JSON.stringify(result));
                break;
                
            case 'clear-cache':
                clearCache();
                channel.send(JSON.stringify({ status: 'ok', message: 'Cache cleared' }));
                break;
                
            case 'stats':
                const stats = getStats();
                channel.send(JSON.stringify({ status: 'ok', stats }));
                break;
                
            case 'ping':
                channel.send(JSON.stringify({ status: 'ok', message: 'pong', timestamp: Date.now() }));
                break;
                
            default:
                console.warn('Unknown command:', message.cmd);
                channel.send(JSON.stringify({ 
                    status: 'error', 
                    error: `Unknown command: ${message.cmd}` 
                }));
        }
        
    } catch (error) {
        console.error('Message handling error:', error);
        channel.send(JSON.stringify({ 
            status: 'error', 
            error: error.message 
        }));
    }
}

// Set up message listener
if (channel.on) {
    channel.on('message', handleMessage);
} else {
    // For testing without React Native bridge
    process.stdin.on('data', (data) => {
        handleMessage(data.toString().trim());
    });
}

// Worker ready signal
setTimeout(() => {
    console.log('✅ Node.js Build Worker ready');
    channel.send(JSON.stringify({ 
        status: 'ready', 
        worker: 'XRAiAssistant Build Worker',
        version: '2.0.0',
        capabilities: ['esbuild', 'caching', 'typescript', 'jsx', 'react-three-fiber']
    }));
}, 100);

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        buildCode,
        clearCache,
        getStats,
        handleMessage
    };
}